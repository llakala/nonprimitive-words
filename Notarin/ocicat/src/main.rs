use rayon::iter::ParallelIterator;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::{Duration, Instant};
use rayon::iter::IntoParallelIterator;

const MAX_DIGITS: usize = 20;

fn has_property(num: usize) -> bool {
    let mut digits: [u8; 20] = [0u8; MAX_DIGITS];
    let mut len: usize = 0;

    if num == 0 {
        digits[0] = 0;
        len = 1;
    } else {
        let mut n: usize = num;
        while n > 0 {
            digits[len] = (n % 10) as u8;
            n /= 10;
            len += 1;
        }
    }

    digits[0..len].reverse();
    for split in 2..=len {
        if len % split == 0 {
            let width: usize = len / split;
            let piece: &[u8] = &digits[0..width];

            let mut is_repeating: bool = true;
            for i in 1..split {
                let chunk = &digits[i * width..(i + 1) * width];
                if chunk != piece {
                    is_repeating = false;
                    break;
                }
            }

            if is_repeating {
                return true;
            }
        }
    }

    false
}

fn main() {
    let start_time: Instant = Instant::now();

    let counter: AtomicUsize = AtomicUsize::new(0);

    (11..10_000_000usize)
        .into_par_iter()
        .for_each(|num| {
            if has_property(num) {
                println!("{} has this property!", num);
                counter.fetch_add(1, Ordering::Relaxed);
            }
        });

    println!("Total found: {}", counter.load(Ordering::Relaxed));

    let elapsed: Duration = start_time.elapsed();
    println!("Elapsed time: {:.2?}", elapsed);
}
