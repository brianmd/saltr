module Saltr
  class Salt
    attr_accessor :options, :target, :function, :args
  end

  class SaltOptions
    attr_accessor :outter, :verbose, :color
  end
end

