# -*- coding: utf-8 -*-
module GenericFileHelper
  def display_title(gf)
    gf.to_s
  end

  def required?(key)
    [:title, :creator, :tag, :rights].include?(key)
  end

  def render_show_field_partial(key, locals)
    render_show_field_partial_with_action('generic_files', key, locals)
  end

  def render_edit_field_partial(key, locals)
    render_edit_field_partial_with_action('generic_files', key, locals)
  end

  def render_batch_edit_field_partial(key, locals)
    render_edit_field_partial_with_action('batch_edit', key, locals)
  end

  def render_download_icon(title=nil)
    link_target = download_image_tag(title) + title
    title ||= "Download the document"
    link_to link_target, sufia.download_path(@generic_file), { target: "_blank", title: title, id: "file_download", data: { label: @generic_file.to_param } }
  end

  def render_download_link(text='Download')
    link_to text, sufia.download_path(@generic_file), { id: "file_download", target: "_new", data: { label: @generic_file.to_param } }
  end

  def render_collection_list(gf)
    "Part of: #{linked_collection_titles(gf).join(", ")}".html_safe if gf.collections.present?
  end

  private

  def render_edit_field_partial_with_action(action, key, locals)
    ["#{action}/edit_fields/#{key}", "#{action}/edit_fields/default"].each do |str|
      # XXX rather than handling this logic through exceptions, maybe there's a Rails internals method
      # for determining if a partial template exists..
      begin
        return render partial: str, locals: locals.merge({ key: key })
      rescue ActionView::MissingTemplate
        nil
      end
    end
  end

  def render_show_field_partial_with_action(action, key, locals)
    ["#{action}/show_fields/#{key}", "#{action}/show_fields/default"].each do |str|
      # XXX rather than handling this logic through exceptions, maybe there's a Rails internals method
      # for determining if a partial template exists..
      begin
        return render partial: str, locals: locals.merge({ key: key })
      rescue ActionView::MissingTemplate
        nil
      end
    end
  end

  def more_or_less_button(key, html_class, symbol)
    # TODO, there could be more than one element with this id on the page, but the fuctionality doesn't work without it.
    content_tag('button', class: "#{html_class} btn", id: "additional_#{key}_submit", name: "additional_#{key}") do
      (symbol + content_tag('span', class: 'sr-only') do
        "add another #{key.to_s}"
      end).html_safe
    end
  end

  def download_image_tag(title=nil)
    if title
      image_tag sufia.download_path(@generic_file, datastream_id: 'thumbnail'), { class: "img-responsive", alt: "#{title} of #{@generic_file.title.first}" }
    else
      image_tag "default.png", { alt: "No preview available", class: "img-responsive" }
    end
  end

  def linked_collection_titles(gf)
    gf.collections.map do |c|
      link_to(c.title, collections.collection_path(c))
    end
  end
end
