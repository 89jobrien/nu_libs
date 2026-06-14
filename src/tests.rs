#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_leibniz_convergence() {
        let algo = Leibniz;
        let pi_1000 = algo.approximate(1_000);
        assert!((pi_1000 - std::f64::consts::PI).abs() < 0.01);
    }

    #[test]
    fn test_monte_carlo() {
        let algo = MonteCarlo::default();
        let pi_hat = algo.approximate(1_000_000);
        // With 1e6 iterations the error is typically < 0.001
        assert!((pi_hat - std::f64::consts::PI).abs() < 0.002);
    }
}
