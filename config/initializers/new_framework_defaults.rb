# Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
# Previous versions had false.
ActiveSupport.to_time_preserves_timezone = true

# Do not halt callback chains when a callback returns false. Previous
# versions had true.
ActiveSupport.halt_callback_chains_on_return_false = false
