class Class < Module
  def self.new(Class superclass)
    FoundryRt.new_class superclass
  end

  def coerce(object)
    object
  end

  def allocate
    FoundryRt.allocate self
  end

  def new(*args, &block)
    instance = allocate
    instance.initialize(*args, &block)
    instance
  end

  def superclass
    klass = @superclass

    while klass.is_a? Foundry::IncludedModule
      klass = klass.direct_superclass
    end

    klass
  end

  def ancestors
    klass     = self
    ancestors = []

    until klass.nil?
      if klass.is_a? Foundry::IncludedModule
        ancestors += [ klass.module ]
      else
        ancestors += [ klass ]
      end

      klass = klass.direct_superclass
    end

    ancestors
  end

  def parametric_by(*names)
    @parameters = @parameters + names
  end

  def parameters
    @parameters
  end

  def reify(specializations)
    FoundryRt.reify self, specializations
  end

  def value_type!
    @specializations[:by_value] = true
  end
end
