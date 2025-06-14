// get the 2008 posix standards, so the time thing works
// the only other standard is from 1993 ok this is sorta new
#define _POSIX_C_SOURCE 200809L

#include <fcntl.h>
#include <linux/input.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <sys/select.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <stdbool.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <time.h>  


// arbitrary number. If this breaks ur setup, increase it.
#define DEVICES_BUFFER_AMOUNT 256

#define DEVICE_PATH "/dev/input/"
#define SOCKET_PATH "/tmp/orca_com.sock"

char *keymap[KEY_MAX + 1];

void grab_all(int *fds, int count) {
    for (int i = 0; i < count; ++i) {
        if (ioctl(fds[i], EVIOCGRAB, 1) == -1) {
            perror("grab failed, is this running as root?");
        }
    }
}

void release_all(int *fds, int count) {
    for (int i = 0; i < count; ++i) {
        ioctl(fds[i], EVIOCGRAB, 0);
    }
}

void init_keymap() {
    memset(keymap, 0, sizeof(keymap));
    keymap[KEY_A] = "a"; keymap[KEY_B] = "b"; keymap[KEY_C] = "c"; keymap[KEY_D] = "d";
    keymap[KEY_E] = "e"; keymap[KEY_F] = "f"; keymap[KEY_G] = "g"; keymap[KEY_H] = "h";
    keymap[KEY_I] = "i"; keymap[KEY_J] = "j"; keymap[KEY_K] = "k"; keymap[KEY_L] = "l";
    keymap[KEY_M] = "m"; keymap[KEY_N] = "n"; keymap[KEY_O] = "o"; keymap[KEY_P] = "p";
    keymap[KEY_Q] = "q"; keymap[KEY_R] = "r"; keymap[KEY_S] = "s"; keymap[KEY_T] = "t";
    keymap[KEY_U] = "u"; keymap[KEY_V] = "v"; keymap[KEY_W] = "w"; keymap[KEY_X] = "x";
    keymap[KEY_Y] = "y"; keymap[KEY_Z] = "z"; keymap[KEY_1] = "1"; keymap[KEY_2] = "2";
    keymap[KEY_3] = "3"; keymap[KEY_4] = "4"; keymap[KEY_5] = "5"; keymap[KEY_6] = "6";
    keymap[KEY_7] = "7"; keymap[KEY_8] = "8"; keymap[KEY_9] = "9"; keymap[KEY_0] = "0";
    keymap[KEY_SPACE] = " "; keymap[KEY_MINUS] = "-"; keymap[KEY_EQUAL] = "=";
    keymap[KEY_SEMICOLON] = ";"; keymap[KEY_COMMA] = ","; keymap[KEY_DOT] = ".";
    keymap[KEY_SLASH] = "/"; keymap[KEY_BACKSLASH] = "\\"; keymap[KEY_APOSTROPHE] = "'";
    keymap[KEY_LEFTBRACE] = "["; keymap[KEY_RIGHTBRACE] = "]";
}

int is_keyboard(const char *path) {
    int fd = open(path, O_RDONLY);
    if (fd < 0) return 0;

    unsigned long evbit = 0;
    ioctl(fd, EVIOCGBIT(0, sizeof(evbit)), &evbit);

    if (!(evbit & (1 << EV_KEY))) {
        close(fd);
        return 0;
    }

    close(fd);
    return 1;
}

int send_to_socket(const char *message) {
    int sockfd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sockfd < 0) return -1;

    struct sockaddr_un addr = {0};
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, SOCKET_PATH, sizeof(addr.sun_path) - 1);

    if (connect(sockfd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(sockfd);
        return -1;
    }

    write(sockfd, message, strlen(message));
    write(sockfd, "\n", 1);
    close(sockfd);
    return 0;
}

int main() {
    char devname[256];
    struct dirent *de;
    DIR *dir = opendir(DEVICE_PATH);
    if (!dir) {
        perror("opendir");
        return 1;
    }

    init_keymap();

    int fds[DEVICES_BUFFER_AMOUNT];
    int fd_count = 0;

    while ((de = readdir(dir))) {
        if (strncmp(de->d_name, "event", 5) == 0) {
            snprintf(devname, sizeof(devname), "%s%s", DEVICE_PATH, de->d_name);
            if (is_keyboard(devname)) {
                int fd = open(devname, O_RDONLY | O_NONBLOCK);
                if (fd >= 0 && fd_count < DEVICES_BUFFER_AMOUNT) {
                    fds[fd_count++] = fd;
                    printf("Opened %s\n", devname);
                }
            }
        }
    }
    closedir(dir);

    struct input_event ev;
    fd_set readfds;
    char buffer[512] = {0};
    size_t index = 0;
    bool recording = false;

    struct timespec esc_timer = {0, 0};
    // if 500 ms is too much for you then recompile with it changed, but 500 ms fits most setups
    const int ESC_MS_CONST = 500;

    printf("Listening on %d devices\n", fd_count);

    while (1) {
        FD_ZERO(&readfds);
        int max_fd = -1;
        for (int i = 0; i < fd_count; ++i) {
            FD_SET(fds[i], &readfds);
            if (fds[i] > max_fd) max_fd = fds[i];
        }

        int ready = select(max_fd + 1, &readfds, NULL, NULL, NULL);
        if (ready < 0) {
            perror("select");
            break;
        }

        for (int i = 0; i < fd_count; ++i) {
            if (FD_ISSET(fds[i], &readfds)) {
                while (read(fds[i], &ev, sizeof(ev)) > 0) {
                    if (ev.type == EV_KEY && ev.value == 1) {
                        if (ev.code == KEY_ESC) {
                            struct timespec now;
                            clock_gettime(CLOCK_MONOTONIC, &now);
                            long diff_ms = (now.tv_sec - esc_timer.tv_sec) * 1000 +
                                           (now.tv_nsec - esc_timer.tv_nsec) / 1000000;

                            if (diff_ms <= ESC_MS_CONST) {
                                grab_all(fds, fd_count);
                                recording = true;
                                index = 0;
                                buffer[0] = '\0';
                            }

                            esc_timer = now;
                        } else if (ev.code == KEY_ENTER && recording) {
                            release_all(fds, fd_count);
                            recording = false;
                            buffer[index] = '\0';
                            
                            struct timespec ts;
                            ts.tv_sec = 0;
                            ts.tv_nsec = 50 * 1000 * 1000; // 500 million nanoseconds = 0.5 seconds
                            nanosleep(&ts, NULL);
                            
                            esc_timer.tv_sec = 0;
                            esc_timer.tv_nsec = 0;
                            
                            if (send_to_socket(buffer) != 0) {
                                perror("Could not connect to socket - no commands will work. If this is running as an installed systemd app, reboot. If that does not fix it, reinstall.");
                            }
                            index = 0;

                        } 
                        else if (ev.code == KEY_BACKSPACE && recording) {
                            
                            if (index > 0) {
                                index--;
                                buffer[index] = '\0'; 
                            }
                        }
                        else if (recording && ev.code <= KEY_MAX && keymap[ev.code]) {
                            size_t len = strlen(keymap[ev.code]);
                            if (index + len < sizeof(buffer)) {
                                strcpy(&buffer[index], keymap[ev.code]);
                                index += len;
                            }
                        }
                    }
                }
            }
        }
    }

    for (int i = 0; i < fd_count; ++i) close(fds[i]);
    return 0;
}
