module RedboxHelper
  
  def link_to_redbox(name, id, html_options = {})
    @uses_redbox = true
    link_to_function name, "RedBox.showInline('#{id.to_s}')", html_options
  end
  
  def link_to_component_redbox(name, url_options = {}, html_options = {})
    @uses_redbox = true
    id = id_from_url(url_options, html_options[:id])
    link_to_redbox(name, id, html_options) + content_tag("span", render_component(url_options), :id => id, :style => 'display: none;')
  end
  
  def link_to_remote_redbox(name, link_to_remote_options = {}, html_options = {})
    @uses_redbox = true
    id = id_from_url(link_to_remote_options[:url], html_options[:id])
    hidden_content_id = "hidden_content_#{id}"
    link_to_remote_options = redbox_remote_options(link_to_remote_options, hidden_content_id)
    
    return build_hidden_content(hidden_content_id) + link_to_remote(name, link_to_remote_options, html_options)
  end
  
  def link_to_close_redbox(name, html_options = {})
    @uses_redbox = true
    link_to_function name, 'RedBox.close()', html_options
  end
  
  def button_to_close_redbox(name, html_options = {})
    @uses_redbox = true
    button_to_function name, 'RedBox.close()', html_options
  end  
  
  def launch_remote_redbox(link_to_remote_options = {}, html_options = {})
    @uses_redbox = true
    id = id_from_url(link_to_remote_options[:url], html_options[:id])
    hidden_content_id = "hidden_content_#{id}"
    hidden_content = build_hidden_content(hidden_content_id)
    link_to_remote_options = redbox_remote_options(link_to_remote_options, hidden_content_id)
    
    return build_hidden_content(hidden_content_id) + javascript_tag(remote_function(link_to_remote_options))
  end
  
private

  def id_from_url(url_options, link_id)
    result = ''
    result = link_id.to_s + '_' unless link_id.nil?
    
    if url_options.nil?
      raise ArgumentError, 'You are trying to create a RedBox link without specifying a valid url.'
    elsif url_options.is_a? String
      result + url_options.delete(":/")
    else
      result + url_to_id_string(url_options.values.join('_'))
    end
  end
  
  def url_to_id_string(value)
    value.sub(/[?=&]/, '')
  end

  def build_hidden_content(hidden_content_id)
    content_tag("div", '', :id => hidden_content_id, :style => 'display: none;')
  end
  
  def redbox_remote_options(remote_options, hidden_content_id)
    remote_options[:update] = hidden_content_id unless remote_options.key?(:update)
    remote_options[:loading] = "RedBox.loading();" + remote_options[:loading].to_s
    if remote_options[:update]
      remote_options[:complete] = "RedBox.addHiddenContent('#{hidden_content_id}'); " + remote_options[:complete].to_s
    else
      remote_options[:complete] = "RedBox.activateRBWindow(); " + remote_options[:complete].to_s
    end
    remote_options
  end
  
  
end
