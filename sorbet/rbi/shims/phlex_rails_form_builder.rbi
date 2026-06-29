# typed: true

class PhlexRailsFormBuilder
  # == Attributes ==

  def object; end
  def object_name; end
  def options; end

  # == Fields ==

  def button(value = T.unsafe(nil), options = T.unsafe(nil), &block); end
  def check_box(method, options = T.unsafe(nil), checked_value = T.unsafe(nil), unchecked_value = T.unsafe(nil)); end
  def checkbox(method, options = T.unsafe(nil), checked_value = T.unsafe(nil), unchecked_value = T.unsafe(nil)); end
  def collection_check_boxes(method, collection, value_method, text_method, options = T.unsafe(nil), html_options = T.unsafe(nil), &block); end
  def collection_checkboxes(method, collection, value_method, text_method, options = T.unsafe(nil), html_options = T.unsafe(nil), &block); end
  def collection_radio_buttons(method, collection, value_method, text_method, options = T.unsafe(nil), html_options = T.unsafe(nil), &block); end
  def collection_select(method, collection, value_method, text_method, options = T.unsafe(nil), html_options = T.unsafe(nil)); end
  def color_field(method, options = T.unsafe(nil)); end
  def date_field(method, options = T.unsafe(nil)); end
  def date_select(method, options = T.unsafe(nil), html_options = T.unsafe(nil)); end
  def datetime_field(method, options = T.unsafe(nil)); end
  def datetime_local_field(method, options = T.unsafe(nil)); end
  def datetime_select(method, options = T.unsafe(nil), html_options = T.unsafe(nil)); end
  def email_field(method, options = T.unsafe(nil)); end
  def emitted_hidden_id?; end
  def field_id(method, *suffixes, namespace: T.unsafe(nil), index: T.unsafe(nil)); end
  def field_name(method, *methods, multiple: T.unsafe(nil), index: T.unsafe(nil)); end
  def fields(scope = T.unsafe(nil), model: T.unsafe(nil), **options, &block); end
  def fields_for(record_name, record_object = T.unsafe(nil), fields_options = T.unsafe(nil), &block); end
  def file_field(method, options = T.unsafe(nil)); end
  def grouped_collection_select(method, collection, group_method, group_label_method, option_key_method, option_value_method, options = T.unsafe(nil), html_options = T.unsafe(nil)); end
  def hidden_field(method, options = T.unsafe(nil)); end
  def id; end
  def label(method, text = T.unsafe(nil), options = T.unsafe(nil), &block); end
  def month_field(method, options = T.unsafe(nil)); end
  def number_field(method, options = T.unsafe(nil)); end
  def password_field(method, options = T.unsafe(nil)); end
  def phone_field(method, options = T.unsafe(nil)); end
  def radio_button(method, tag_value, options = T.unsafe(nil)); end
  def range_field(method, options = T.unsafe(nil)); end
  def rich_text_area(method, options = T.unsafe(nil), &block); end
  def rich_textarea(method, options = T.unsafe(nil), &block); end
  def search_field(method, options = T.unsafe(nil)); end
  def select(method, choices = T.unsafe(nil), options = T.unsafe(nil), html_options = T.unsafe(nil), &block); end
  def submit(value = T.unsafe(nil), options = T.unsafe(nil)); end
  def telephone_field(method, options = T.unsafe(nil)); end
  def text_area(method, options = T.unsafe(nil)); end
  def text_field(method, options = T.unsafe(nil)); end
  def textarea(method, options = T.unsafe(nil)); end
  def time_field(method, options = T.unsafe(nil)); end
  def time_select(method, options = T.unsafe(nil), html_options = T.unsafe(nil)); end
  def time_zone_select(method, priority_zones = T.unsafe(nil), options = T.unsafe(nil), html_options = T.unsafe(nil)); end
  def url_field(method, options = T.unsafe(nil)); end
  def week_field(method, options = T.unsafe(nil)); end
  def weekday_select(method, options = T.unsafe(nil), html_options = T.unsafe(nil)); end
end
