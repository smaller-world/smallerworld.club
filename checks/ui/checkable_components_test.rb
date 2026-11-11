# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class CheckableComponentsTest < ApplicationSystemTestCase
  setup do
    visit root_path
    markup = <<~HTML
      <form id="checkables">
        <label id="notifications-label" for="switch-input">notifications</label>
        #{Components::Switch.new(id: "switch-input", name: "notifications", value: "1", aria: { labelledby: "notifications-label" }).call}
        <label for="small-switch-input">small switch</label>
        #{Components::Switch.new(id: "small-switch-input", size: :sm, checked: true, invalid: true).call}
        <label for="disabled-switch-input">disabled switch</label>
        #{Components::Switch.new(id: "disabled-switch-input", name: "disabled", disabled: true).call}
        <label for="checkbox-input">checkbox</label>
        #{Components::Checkbox.new(id: "checkbox-input", name: "checkbox", aria: { label: "custom checkbox label" }).call}
        <label for="disabled-checkbox-input">disabled checkbox</label>
        #{Components::Checkbox.new(id: "disabled-checkbox-input", disabled: true).call}
        <label for="disabled-radio-input">disabled radio</label>
        #{Components::RadioGroupItem.new(id: "disabled-radio-input", name: "disabled", value: "one", disabled: true).call}
        <label for="disabled-toggleable-radio-input">disabled toggleable radio</label>
        #{Components::RadioGroupItem.new(id: "disabled-toggleable-radio-input", name: "disabled", value: "two", disabled: true, toggleable: true).call}
        <label id="radio-one-label">
          first radio
          #{Components::RadioGroupItem.new(name: "radio", value: "one", checked: true).call}
        </label>
        <label>
          second radio
          #{Components::RadioGroupItem.new(name: "radio", value: "two").call}
        </label>
        <button type="submit" name="save" value="1">save controls</button>
        <button type="reset">reset controls</button>
      </form>
    HTML
    page.execute_script(<<~JS, markup)
      document.body.insertAdjacentHTML("beforeend", arguments[0]);
      document.getElementById("checkables").addEventListener("submit", (event) => {
        event.preventDefault();
        event.currentTarget.dataset.submitted = event.submitter.name;
      });
    JS
    assert_selector '#checkables [role="switch"][aria-labelledby="small-switch-input_label"]'
  end

  test "proxy associates native labels and preserves explicit accessible names" do
    assert_selector '[role="switch"][data-size="sm"][aria-labelledby="small-switch-input_label"]'
    assert_selector 'label#small-switch-input_label[for="small-switch-input"]'
    assert_selector '[role="switch"][aria-labelledby="notifications-label"]'
    assert_selector '[role="checkbox"][aria-label="custom checkbox label"]:not([aria-labelledby])'
    assert_selector '[role="radio"][aria-labelledby="radio-one-label"]'
    assert_equal "second radio", find('[role="radio"][data-unchecked]:not([data-disabled])').evaluate_script(
      "document.getElementById(this.getAttribute('aria-labelledby')).textContent.trim()",
    )
  end

  test "checkable markup exposes state on the proxy and hides the native input" do
    optional_states = %w[disabled readonly required invalid]
    active_states = %w[checked disabled readonly required invalid]
    native_states = %w[checked disabled readonly required]
    [ Components::Checkbox, Components::Switch, Components::RadioGroupItem ].each do |component|
      document = Nokogiri::HTML.fragment(component.new.call)
      proxy = document.at_css("[role]")
      input = document.at_css("input")
      assert_equal "false", proxy["aria-checked"]
      optional_states.each do |state|
        assert_nil proxy["aria-#{state}"]
      end
      assert_equal "true", input["aria-hidden"]
      assert_equal "-1", input["tabindex"]

      document = Nokogiri::HTML.fragment(component.new(
        checked: true, disabled: true, readonly: true, required: true, invalid: true,
        form: "external-form", aria: { label: "control", describedby: "description" },
      ).call)
      proxy = document.at_css("[role]")
      input = document.at_css("input")
      active_states.each do |state|
        assert_equal "true", proxy["aria-#{state}"]
      end
      assert_equal "control", proxy["aria-label"]
      assert_equal "description", proxy["aria-describedby"]
      assert_equal "-1", proxy["tabindex"]
      native_states.each do |state|
        assert input.key?(state)
        assert_not proxy.key?(state)
      end
      assert_equal "external-form", input["form"]
      assert_not proxy.key?("form")
      assert_equal "true", input["aria-hidden"]
    end
  end

  test "proxy keeps aria state synchronized with the native input" do
    markup = [ Components::Checkbox, Components::Switch, Components::RadioGroupItem ].each_with_index.map do |component, index|
      id = "aria-checkable-#{index}"
      "<label for=\"#{id}\">control</label>" + component.new(id:, checked: true, disabled: true, readonly: true, required: true).call
    end.join
    page.execute_script(<<~JS, markup)
      document.body.insertAdjacentHTML("beforeend", '<div id="aria-checkables">' + arguments[0] + '</div>');
    JS
    assert_selector '#aria-checkables [role][aria-labelledby][aria-checked="true"][aria-disabled="true"][aria-readonly="true"][aria-required="true"]', count: 3

    page.execute_script(<<~JS)
      for (const input of document.querySelectorAll("#aria-checkables input")) {
        input.checked = false;
        input.disabled = false;
        input.readOnly = false;
        input.required = false;
        input.dispatchEvent(new Event("change"));
      }
    JS
    assert_selector '#aria-checkables [role][aria-checked="false"][tabindex="0"]:not([aria-disabled]):not([aria-readonly]):not([aria-required])', count: 3
  end

  test "readonly checkboxes retain their values through pointer, label and keyboard activation" do
    markup = <<~HTML
      <form id="readonly-controls">
        <label for="readonly-checked">readonly checked</label>
        #{Components::Checkbox.new(id: "readonly-checked", name: "checked", value: "1", checked: true, readonly: true).call}
        <label for="readonly-unchecked">readonly unchecked</label>
        #{Components::Checkbox.new(id: "readonly-unchecked", name: "unchecked", value: "1", readonly: true).call}
      </form>
    HTML
    page.execute_script('document.body.insertAdjacentHTML("beforeend", arguments[0])', markup)
    assert_selector '#readonly-controls [role="checkbox"][data-readonly][aria-readonly="true"][tabindex="0"]', count: 2

    within("#readonly-controls") do
      all('[role="checkbox"]').each do |control|
        control.click
        control.send_keys(:space)
        control.send_keys(:enter)
      end
      all("label").each(&:click)
      all('input[type="checkbox"]', visible: :all).each do |input|
        input.execute_script("this.click()")
      end
      assert_selector '#readonly-checked:checked', visible: :all
      assert_no_selector '#readonly-unchecked:checked', visible: :all
      assert_selector '[role="checkbox"][aria-checked="true"]', count: 1
      assert_selector '[role="checkbox"][aria-checked="false"]', count: 1
    end

    assert_equal "1", page.evaluate_script('new FormData(document.getElementById("readonly-controls")).get("checked")')
    assert_nil page.evaluate_script('new FormData(document.getElementById("readonly-controls")).get("unchecked")')
  end

  test "form switch uses model state, validation errors and Rails boolean values" do
    post = Post.new(quiet: true)
    post.errors.add(:quiet, "is invalid")
    markup = Components::Form.new(post, action: "/", method: :get, id: "builder-switch").call do |form|
      form.wrapped(form.field(:quiet).switch(size: :sm))
    end
    page.execute_script('document.body.insertAdjacentHTML("beforeend", arguments[0])', markup)

    within("#builder-switch") do
      assert_selector '[role="switch"][aria-labelledby="post_quiet_label"][aria-invalid="true"][data-size="sm"]'
      assert_selector 'label#post_quiet_label[for="post_quiet"]'
      assert_selector '#post_quiet:checked', visible: :all
      assert_selector 'input[type="hidden"][name="post[quiet]"][value="0"]', visible: :all
      assert_selector '#post_quiet[name="post[quiet]"][value="1"]', visible: :all
    end

    query = page.evaluate_script('new URLSearchParams(new FormData(document.getElementById("builder-switch"))).toString()')
    assert_equal "1", Rack::Utils.parse_nested_query(query).dig("post", "quiet")

    find('#builder-switch [role="switch"]').click
    assert_no_selector '#post_quiet:checked', visible: :all
    query = page.evaluate_script('new URLSearchParams(new FormData(document.getElementById("builder-switch"))).toString()')
    assert_equal "0", Rack::Utils.parse_nested_query(query).dig("post", "quiet")
  end

  test "switch toggles with pointer, label, space and enter and resets with its form" do
    switch = find('#checkables [role="switch"][data-size="default"]', match: :first)
    switch.click
    assert_selector '#switch-input:checked', visible: :all
    assert_selector '[role="switch"][data-checked][aria-checked="true"]'
    assert_equal "1", page.evaluate_script('new FormData(document.getElementById("checkables")).get("notifications")')

    find('label[for="switch-input"]').click
    assert_no_selector '#switch-input:checked', visible: :all
    assert_equal switch, page.active_element

    switch.send_keys(:space)
    assert_selector '#switch-input:checked', visible: :all
    switch.send_keys(:enter)
    assert_no_selector '#switch-input:checked', visible: :all
    assert_selector '[role="switch"][data-unchecked][aria-checked="false"]'
    assert_no_selector '#checkables[data-submitted]'

    switch.click
    click_button "reset controls"
    assert_no_selector '#switch-input:checked', visible: :all
    assert_selector '[role="switch"][data-unchecked][aria-checked="false"]'
    assert_selector '#small-switch-input:checked', visible: :all
  end

  test "switch sizes, invalid state and disabled controls" do
    assert_selector '[role="switch"][data-size="sm"][aria-invalid="true"][data-checked]'
    assert_equal 44, find('[role="switch"][data-size="default"]', match: :first).evaluate_script("this.offsetWidth")
    assert_equal 28, find('[role="switch"][data-size="sm"]').evaluate_script("this.offsetWidth")

    [ Components::Checkbox, Components::RadioGroupItem ].each do |component|
      document = Nokogiri::HTML.fragment(component.new(disabled: true).call)
      assert_equal "-1", document.at_css("[role]")&.[]("tabindex")
      assert_equal "true", document.at_css("[role]")&.[]("aria-disabled")
      assert document.at_css("input[disabled]")
    end

    all('#checkables [data-disabled]').each do |control|
      assert_equal "-1", control[:tabindex]
      assert_equal "true", control["aria-disabled"]
      control.execute_script("this.click()")
    end
    find('label[for="disabled-switch-input"]').execute_script("this.click()")
    find('label[for="disabled-radio-input"]').execute_script("this.click()")
    find('label[for="disabled-toggleable-radio-input"]').execute_script("this.click()")
    assert_no_selector '#disabled-switch-input:checked', visible: :all
    assert_no_selector '#disabled-checkbox-input:checked', visible: :all
    assert_no_selector '#disabled-radio-input:checked, #disabled-toggleable-radio-input:checked', visible: :all
    assert_nil page.evaluate_script('new FormData(document.getElementById("checkables")).get("disabled")')
  end

  test "checkbox enter submits without toggling and radio changes stay synchronized" do
    checkbox = find('#checkables [role="checkbox"]', match: :first)
    checkbox.send_keys(:space)
    assert_selector '#checkbox-input:checked', visible: :all
    checkbox.send_keys(:enter)
    assert_selector '#checkables[data-submitted="save"]'
    assert_selector '#checkbox-input:checked', visible: :all
    assert_selector '[role="checkbox"][aria-checked="true"]'

    all('#checkables [role="radio"]').last.click
    assert_selector '[role="radio"][data-checked][aria-checked="true"]', count: 1
    assert_selector '[role="radio"][data-unchecked][aria-checked="false"]:not([data-disabled])', count: 1
    assert_selector 'input[type="radio"][value="two"]:checked', visible: :all
  end
end
