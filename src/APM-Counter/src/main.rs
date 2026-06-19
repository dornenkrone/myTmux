#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::sync::{Arc, Mutex};
use std::thread::sleep;
use std::time::Duration;
use std::fs;
// use std::io::Write;

use rdev::{listen, Event, EventType, Key};

#[derive(Debug, Default)]
struct State {
    shutdown: bool,
    actions_count: u64,
    elapsed: u64,              // 100ms ticks, resets every 600 ticks (1 min)
    apm: u64,
    average_elapsed: u64,      // 100ms ticks for average (resets at huge value)
    average_apm: u64,
    average_actions_count: u64,
}

/// Write the current APM and average to `/tmp/apm_counting`
fn write_status(state: &State) {
    let content = format!("apm: {} | avg: {}\n", state.apm, state.average_apm);
    let _ = fs::write("/tmp/apm_counting", content); // ignore errors (e.g., permission)
}

fn callback(event: Event, state: &mut Arc<Mutex<State>>) {
    match event.event_type {
        EventType::KeyRelease(_) | EventType::ButtonRelease(_) => {
            let mut state = state.lock().unwrap();

            if let EventType::KeyRelease(key) = event.event_type {
                if key == Key::End {
                    state.shutdown = true;
                    return;
                }
            }

            state.actions_count += 1;
            state.average_actions_count += 1;
        }
        _ => (),
    }
}

fn main() {
    let state = Arc::new(Mutex::new(State::default()));
    
    let state_clone = Arc::clone(&state);
    std::thread::spawn(move || {
        if let Err(error) = listen(move |e| callback(e, &mut state_clone.clone())) {
            eprintln!("Listener error: {:?}", error);
        }
    });

    // --- Thread 2: APM counter (every 100ms) ---
    let state_clone = Arc::clone(&state);
    std::thread::spawn(move || {
        loop {
            let mut state_guard = state_clone.lock().unwrap();

            if state_guard.shutdown {
                break;
            }

            // Update 1‑minute APM
            if state_guard.elapsed == 600 {
                state_guard.apm = state_guard.actions_count;
                state_guard.actions_count = 0;
                state_guard.elapsed = 0;
            } else {
                state_guard.elapsed += 1;
                let time = state_guard.elapsed as f64 / 10.0; // seconds? Actually 100ms ticks -> seconds
                state_guard.apm = (state_guard.actions_count as f64 / time * 60.0) as u64;
            }

            // Update average (over a very long period, matching original logic)
            if state_guard.average_elapsed == 600 * 60 * 60 {
                state_guard.average_apm = state_guard.apm;
                state_guard.average_actions_count = 0;
                state_guard.average_elapsed = 0;
            } else {
                state_guard.average_elapsed += 1;
                let time = state_guard.average_elapsed as f64 / 600.0; // minutes
                state_guard.average_apm = if time > 0.0 {
                    (state_guard.average_actions_count as f64 / time) as u64
                } else {
                    0
                };
            }

            drop(state_guard);
            sleep(Duration::from_millis(250));
        }
    });

    // --- Main thread: write status to file every 500ms ---
    loop {
        let state_guard = state.lock().unwrap();
        if state_guard.shutdown {
            break;
        }
        write_status(&state_guard);
        drop(state_guard);
        sleep(Duration::from_millis(1000));
    }
}
