//! Approximates pi with Leibniz-series and Monte Carlo algorithms.

mod pi_approximator;
#[cfg(test)]
mod tests;

pub use pi_approximator::{Leibniz, MonteCarlo, PiApproximator};
