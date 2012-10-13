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

$.fn.gain = (message) ->
    $gain = $ "<div class='gain'>
          <h1>#{message}</h1>
        </div>"
    location = @.offset()
    $gain.css
        position: "fixed"
        "z-index": 1000
        left: location.left
        top: location.top
        color: "#468847"
    $("body").append $gain
    $gain.animate(
            opacity: 0
            top: location.top - 42
        1000
        -> $gain.remove())

$.checkLevel = (server_result) ->
    if server_result.new_level_label?
        $(".character-level").text server_result.new_level_label
    if server_result.levels_gained?
        if server_result.levels_gained == 1
            $(".character-level").gain "+#{server_result.levels_gained}&nbsp;level"
        else if server_result.levels_gained > 1
            $(".character-level").gain "+#{server_result.levels_gained}&nbsp;levels"

$.checkXp = (server_result) ->
    if server_result.new_xp_total?
        $(".character-xp").text "#{server_result.new_xp_total} xp"
    if server_result.xp_gained? && server_result.xp_gained > 0
        $(".character-xp").gain "+#{server_result.xp_gained}&nbsp;xp"

$ ->
    if $.canEdit()
        $(".tome-item").click ->
            $(".tome-item-clicked").removeClass "tome-item-clicked"
            $(@).addClass "tome-item-clicked"
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
                        $.checkXp result
                    error: ->
                        # TODO
                false
            $target.after $form
            $(@).click ->
                $target.hide()
                $form.show()
                $input.focus()
                false
