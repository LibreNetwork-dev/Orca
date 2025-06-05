// testing having one thing running as root and another running,, not as root.
// the thing runnign as root captures key inputs and sends them to tmp/orca_com.sock
// this is for wayland support
use std::os::unix::net::UnixListener;
use std::io::{BufRead, BufReader};
use std::process::Command;
use std::thread;

fn main() {
    let sock_path = "/tmp/orca_com.sock";
    let _ = std::fs::remove_file(sock_path); 

    let listener = UnixListener::bind(sock_path)
        .expect("Failed to bind to socket");

    println!("Listening on {}", sock_path);

    for stream in listener.incoming() {
        if let Ok(stream) = stream {
            let reader = BufReader::new(stream);
            for line in reader.lines() {
                match line {
                    Ok(cmd_line) => {
                        if cmd_line.trim().is_empty() {
                            continue;
                        }
                        let mut parts = cmd_line.trim().split_whitespace();
                        if let Some(base) = parts.next() {
                            
                            let script_path = format!("lib/{}.lua", base);
                            let args: Vec<String> = parts.map(String::from).collect();

                            println!("Running: luajit {} {:?}", script_path, args);

                            thread::spawn(move || {
                                Command::new("luajit")
                                    .arg(&script_path)
                                    .args(&args)
                                    .spawn() 
                                    .expect("failed to spawn luajit");
                            });
                        }
                    }
                    Err(e) => eprintln!("Error reading line: {:?}", e),
                }
            }
        }
    }
}
