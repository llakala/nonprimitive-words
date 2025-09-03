use clap::Parser;
use rayon::iter::IntoParallelIterator;
use rayon::iter::ParallelIterator;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::{Duration, Instant};

const MAX_DIGITS: usize = 20;

#[derive(Parser)]
#[command(version, about, author)]
struct Args {
    #[clap(
        short,
        long,
        env,
        default_value = "10000000",
        help = "How many numbers to check against."
    )]
    max_checks: usize,
    #[clap(
        short,
        long,
        env,
        default_value = "true",
        help = "Whether to print benchmark info."
    )]
    benchmark: bool,
    #[clap(
        short,
        long,
        env,
        default_value = "11",
        help = "First number to start at."
    )]
    starting_num: usize,
}

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
    let Args { max_checks, benchmark, starting_num }: Args = Args::parse();

    let start_time: Instant = Instant::now();

    let counter: AtomicUsize = AtomicUsize::new(0);

    (starting_num..max_checks).into_par_iter().for_each(|num| {
        if has_property(num) {
            println!("{} has this property!", num);
            counter.fetch_add(1, Ordering::Relaxed);
        }
    });

    println!("Total found: {}", counter.load(Ordering::Relaxed));

    if benchmark {
        let elapsed: Duration = start_time.elapsed();
        println!("Elapsed time: {:.2?}", elapsed);
    }
}
