# Return a random value in the range based on the rspec seed.
#
# @param range [Array<Object>] The range to select from.
# @return [Object] A randomly select member of the range.
def seeded_rand(range)
  Random.new(RSpec.configuration.seed).rand(range)
end
