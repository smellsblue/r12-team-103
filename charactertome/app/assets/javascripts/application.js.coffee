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
$ ->
    $("a.edit-tome-item").each ->
        target = $(@).data "for"
        $target = $ "##{target}-value"
        placeholder = $target.data "input-placeholder"
        form = $ "<form class='tome-edit-form' id='form-for-#{target}' style='display: none;'>
              <input type='hidden' name='_method' value='PUT' />
              <input type='text' name='#{target}' placeholder='#{placeholder}' />
            </form>"
        $input = form.find "input[name='#{target}']"
        $input.val $target.data("original-value")
        form.submit ->
            $.ajax "/tomes/#{$("#tome_id").val()}",
                type: "POST"
                data: $(@).serialize()
                success: ->
                    $target.text $input.val()
                    $target.text placeholder unless $input.val().length
                    form.hide()
                    $target.show()
                error: ->
                    # TODO
            false
        $target.after form
    $("a.edit-tome-item").click ->
        $("##{$(@).data("for")}-value").hide()
        $("#form-for-#{$(@).data("for")}").show()
        false
