# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require_tree .

$.canEdit = () ->
    $("#can_edit").val() == "true"

$.checkLevel = (server_result) ->
    if server_result.new_level_label?
        $(".character-level").text server_result.new_level_label

$ ->
    if $.canEdit()
        $("a.edit-tome-item").each ->
            target = $(@).data "for"
            $target = $ "##{target}-value"
            placeholder = $target.data "input-placeholder"
            $form = $ "<form class='tome-edit-form' id='form-for-#{target}' style='display: none;'>
                  <input type='hidden' name='_method' value='PUT' />
                  <input type='hidden' name='attribute' value='#{target}' />
                  <input type='text' name='value' placeholder='#{placeholder}' />
                </form>"
            $input = $form.find "input[name='value']"
            $input.val $target.data("original-value")
            $form.submit ->
                $.ajax "/tomes/#{$("#tome_id").val()}",
                    type: "POST"
                    data: $(@).serialize()
                    success: (result) ->
                        if result.new_value?.length
                            $target.text result.new_value
                        else
                            $target.text placeholder
                        $form.hide()
                        $target.show()
                        $.checkLevel result
                    error: ->
                        # TODO
                false
            $target.after $form
            $(@).click ->
                $target.hide()
                $form.show()
                $input.focus()
                false
