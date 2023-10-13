# frozen_string_literal: true
require 'active_fedora/attribute_methods/read'
require 'active_fedora/attribute_methods/write'

ActiveFedora::AttributeMethods::Read::ClassMethods.class_eval do
  protected

  # Patch this method to reflect changes between Rails 5 and Rails 6 pertaining
  # to where attribute definitions are managed
  def define_method_attribute(name, owner: nil) # rubocop:disable Lint/UnusedMethodArgument
    name = name.to_s
    safe_name = name.unpack('h*'.freeze).first
    temp_method = "__temp__#{safe_name}"

    ActiveFedora::AttributeMethods::AttrNames.set_name_cache safe_name, name

    generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
              def #{temp_method}
                # The AttributeMethods module has been moved from ActiveRecord to 
                # ActiveModel in Rails >=6.0
                name = ::ActiveFedora::AttributeMethods::AttrNames::ATTR_#{safe_name}
                _read_attribute(name) { |n| missing_attribute(n, caller) }
              end
    STR

    generated_attribute_methods.module_eval do
      alias_method name, temp_method
      undef_method temp_method
    end
  end
end

ActiveFedora::AttributeMethods::Write::ClassMethods.class_eval do
  protected

  def define_method_attribute=(name, owner: nil) # rubocop:disable Lint/UnusedMethodArgument
    name = name.to_s
    safe_name = name.unpack('h*'.freeze).first
    ActiveFedora::AttributeMethods::AttrNames.set_name_cache safe_name, name

    generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
              def __temp__#{safe_name}=(value)
                name = ::ActiveFedora::AttributeMethods::AttrNames::ATTR_#{safe_name}
                write_attribute(name, value)
              end
              alias_method #{(name + '=').inspect}, :__temp__#{safe_name}=
              undef_method :__temp__#{safe_name}=
    STR
  end
end
