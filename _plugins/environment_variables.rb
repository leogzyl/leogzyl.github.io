# Plugin to add environment variables to the `site` object in Liquid templates
module Jekyll
  class EnvironmentVariablesGenerator < Generator
    def generate(site)
      site.config['soopr'] =  {"publish_token" => ENV['SOOPR_PT_TOKEN'] || ''} 
      # site.config['env_vars'] = ENV.to_h
      # Add other environment variables to `site.config` here...
    end
  end
end