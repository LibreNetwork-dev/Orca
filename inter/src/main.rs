use rdev::{listen, Event, EventType, Key};
use std::sync::{Arc, Mutex};
use std::process::Command;
use std::thread;
use std::io::{stdout, Write}; 

// big ass function? big ass function
// also no caps/shift support lol
fn Keytochar(key: Key) -> Option<char> {
    match key {
        Key::KeyA => Some('a'),
        Key::KeyB => Some('b'),
        Key::KeyC => Some('c'),
        Key::KeyD => Some('d'),
        Key::KeyE => Some('e'),
        Key::KeyF => Some('f'),
        Key::KeyG => Some('g'),
        Key::KeyH => Some('h'),
        Key::KeyI => Some('i'),
        Key::KeyJ => Some('j'),
        Key::KeyK => Some('k'),
        Key::KeyL => Some('l'),         
        Key::KeyM => Some('m'),
        Key::KeyN => Some('n'),
        Key::KeyO => Some('o'),
        Key::KeyP => Some('p'),
        Key::KeyQ => Some('q'),
        Key::KeyR => Some('r'),
        Key::KeyS => Some('s'),
        Key::KeyT => Some('t'),
        Key::KeyU => Some('u'),
        Key::KeyV => Some('v'),
        Key::KeyW => Some('w'),
        Key::KeyX => Some('x'),
        Key::KeyY => Some('y'),
        Key::KeyZ => Some('z'),
        Key::Num1 => Some('1'),
        Key::Num2 => Some('2'),
        Key::Num3 => Some('3'),
        Key::Num4 => Some('4'),
        Key::Num5 => Some('5'),
        Key::Num6 => Some('6'),
        Key::Num7 => Some('7'),
        Key::Num8 => Some('8'),
        Key::Num9 => Some('9'),
        Key::Num0 => Some('0'),
        Key::Space => Some(' '),
        Key::Comma => Some(','),
        Key::Dot => Some('.'),
        Key::SemiColon => Some(';'),
        Key::Slash => Some('/'),
        Key::BackSlash => Some('\\'),
        Key::Minus => Some('-'),
        Key::Equal => Some('='),
        _ => None,
    }
}
fn main() {
    let recording = Arc::new(Mutex::new(false));
    let captured_keys = Arc::new(Mutex::new(Vec::new()));
    let recording_clone = Arc::clone(&recording);
    let keys_clone = Arc::clone(&captured_keys);
    

    let callback = move |event: Event| {
        if let EventType::KeyPress(key) = event.event_type {
            let mut is_recording = recording_clone.lock().unwrap();
            let mut keys = keys_clone.lock().unwrap();
    
            match key {
                Key::Escape => {
                    if !*is_recording {
                        *is_recording = true;
                        keys.clear();
                    } else {
                        *is_recording = false;
                    }
                }
                Key::Return => {
                    if *is_recording {
                        *is_recording = false;
                
                        let c_chars: String = keys
                            .iter()
                            .filter_map(|&key| Keytochar(key))
                            .collect();
                        if c_chars.starts_with(';') {
                            if let Some(c) = c_chars.chars().nth(1) {
                                let args: String = c_chars.chars().skip(2).collect();
                                let args_ws: Vec<String> = args
                                    .split_whitespace()
                                    .map(|s| s.to_string())
                                    .collect();
                
                                match c {
                                    'e' => {
                                        let args = args.clone();
                                        if cfg!(target_os = "windows") {
                                            thread::spawn(move || {
                                                Command::new("cmd")
                                                    .args(&["/C", &args])
                                                    .spawn()
                                                    .expect("failed to spawn command");
                                            });
                                        } else {
                                            thread::spawn(move || {
                                                Command::new("sh")
                                                    .arg("-c")
                                                    .arg(&args)
                                                    .spawn()
                                                    .expect("failed to spawn command");
                                            });
                                        }
                                    }
                                    's' => {
                                        thread::spawn(move || {
                                            Command::new("luajit") // luajit is preinstalled by /deps/*
                                                .args(&["lib/browser_search.lua"])
                                                .args(&args_ws)
                                                .status()
                                                .expect("failed to exec search");
                                        });
                                    }
                                    'p' => {;
                                        thread::spawn(move || {
                                            Command::new("luajit")
                                                .args(&["lib/player_search.lua"])
                                                .args(&args_ws)
                                                .status()
                                                .expect("failed to exec play");
                                        });
                                    }
                                    _ => {}
                                }
                            }
                        } else if c_chars.starts_with('/'){
                            if let Some(c) = c_chars.chars().nth(1) {
                                let args: String = c_chars.chars().skip(2).collect();
                                let args_ws: Vec<String> = args
                                    .split_whitespace()
                                    .map(|s| s.to_string())
                                    .collect();
                                
                                match c {
                                    // /k stops audio
                                    'k' => {
                                        thread::spawn(move || {
                                            Command::new("luajit")
                                                .args(&["lib/stopmpv.lua"])
                                                .args(&args_ws)
                                                .status()
                                                .expect("failed to kill mpv");
                                        });
                                    } 
                                    'p' => {
                                        thread::spawn(move || {
                                            Command::new("luajit")
                                            .args(&["lib/pausempv.lua"])
                                            .args(&args_ws)
                                            .status()
                                            .expect("failed to pause audio");

                                        });
                                    }
                                    _ => {}
                                };
                            }                   
                        }
                
                        return;
                    }
                }
                
                Key::Backspace => {
                    if *is_recording {
                        keys.pop();
                    }
                }
                _ => {
                    if *is_recording {
                        if Keytochar(key).is_some() {
                            keys.push(key);
                        }
                    }
                }
            }
    

        }
    };
      
    if let Err(error) = listen(callback) {
        eprintln!("Error: {:?}", error);
        stdout().flush().unwrap();
    }
}
