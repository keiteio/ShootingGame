class Object
  def posterity?(klass)
    return self.ancestors.include?(klass)
  end
end