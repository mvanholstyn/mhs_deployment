class LwtDeploymentGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.template 'Capfile', 'Capfile'
    end
  end
end
