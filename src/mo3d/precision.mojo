# Because mojo doesn't support generic traits yet, we need to use a global precision type for all our calculations. This is a bit of a hack, but it works for now.
alias int_type = DType.int32
alias float_type = DType.float32
