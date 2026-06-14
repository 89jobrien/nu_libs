use rand::Rng;
use std::time::Instant;

/// Trait for approximating π
pub trait PiApproximator {
    /// Approximate π using the algorithm.
    ///
    /// * `terms` – number of terms or iterations; interpretation depends on implementor.
    /// Returns a floating‑point approximation.
    fn approximate(&mut self, terms: usize) -> f64;
}

/// Leibniz series: π = 4 * Σ_{n=0}^{∞} ((-1)^n / (2n + 1))
#[derive(Debug, Default, Clone, Copy)]
pub struct Leibniz;

impl PiApproximator for Leibniz {
    fn approximate(&mut self, terms: usize) -> f64 {
        let mut sum = 0.0_f64;
        for n in 0..terms {
            let term = ((-1i32).pow(n as u32) as f64) / ((2 * n + 1) as f64);
            sum += term;
        }
        4.0 * sum
    }
}

/// Monte‑Carlo approximation: π ≈ 4 * (hits / total)
#[derive(Debug, Clone)]
pub struct MonteCarlo<R: Rng = rand::rngs::ThreadRng> {
    rng: R,
}

impl Default for MonteCarlo<rand::rngs::ThreadRng> {
    fn default() -> Self {
        Self {
            rng: rand::thread_rng(),
        }
    }
}

impl<R: Rng> PiApproximator for MonteCarlo<R> {
    fn approximate(&mut self, terms: usize) -> f64 {
        let mut hits = 0u64;
        for _ in 0..terms {
            let x: f64 = self.rng.gen();
            let y: f64 = self.rng.gen();
            if x * x + y * y <= 1.0 {
                hits += 1;
            }
        }
        4.0 * (hits as f64 / terms as f64)
    }
}

/// Utility to benchmark an approximator
pub fn benchmark<A: PiApproximator>(
    approximator: &mut A,
    terms: usize,
) -> (f64, std::time::Duration) {
    let start = Instant::now();
    let pi = approximator.approximate(terms);
    let duration = start.elapsed();
    (pi, duration)
}
