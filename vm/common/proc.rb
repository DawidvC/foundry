class Proc
  def self.allocate
    raise TypeError, "allocator undefined for Proc"
  end

  def call(*args, &block)
    FoundryRt.apply self, args, block
  end

  alias []  call
  alias === call

  def binding
    @binding
  end

  def lambda_style!
    @lambda = true
  end

  def lambda?
    @lambda
  end

  def arity
    @arity
  end
end