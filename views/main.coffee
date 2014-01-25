makeCounter = ->
  counter = ->
    ++currentCount
  currentCount = 1
  counter.set = (value) ->
    currentCount = value
  counter.reset = ->
    currentCount = 1
  counter

loader = (data, int) ->
  if int == 1
    root.counter.reset();
    $("div#clear-fix").html("<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>")
    $("dl#search-result").html("")
  if root.maxpages >= int
    $.ajax
      type: "get"
      url: "/api/search/#{data}/#{int}"
      beforeSend: (data) ->
        $("#loaderbar").css('display', 'block')
      success: (data) -> 
        if data["status"] == "success"
          root.maxpages = data["pages"]
          html = ""
          id_last = lastprice['id']
          $.each data["result"], (id, hash) =>
            if hash['prices'][id_last] == undefined
              price = "<span class='right'>Нет в наличии</span>"
            else
              price = "<span class='right'><b>#{hash['prices'][id_last]['retail']}</b> <span class='fa fa-rub'></span></span>"

            row = ""
            $.each hash["prices"], (id, hash) =>
              console.log hash
              row += [
                "<tr>",
                  "<td>#{allprice[id]}</td>",
                  "<td>#{hash['retail']}</td>",
                  "<td>#{hash['regular']}</td>",
                  "<td>#{hash['small_wholesale']}</td>",
                  "<td>#{hash['wholesale']}</td>",
                  "<td>#{hash['wholesale_3psc']}</td>",
                  "<td>#{hash['wholesale_5psc']}</td>",
                  "<td>#{hash['wholesale_10psc']}</td>",
                  "<td>#{hash['wholesale_100psc']}</td>",
                  "<td>#{hash['wholesale_1000psc']}</td>",
                "</tr>"
              ].join("")

            if hash['about'] == " "
              about = ""
            else
              about = "<p><b>Описание:</b>  #{hash['about']}</p>"


            html += [
              "<dd>",
                "<a href='##{hash['id']}'>#{hash['sku']} - #{hash['name']}",
                  price,
                "</a>",
                "<div class='content' id='#{hash['id']}'>",
                  "<p><b>Категория:</b> #{categories[hash['category_id']]}</p>",
                  about,
                  "<table>",
                    "<thead>",
                      "<tr>",
                        "<th>Дата</th>",
                        "<th>Розн.</th>",
                        "<th>П. П.</th>",
                        "<th>М. опт</th>",
                        "<th>Опт</th>",
                        "<th>3шт</th>",
                        "<th>5шт</th>",
                        "<th>10шт</th>",
                        "<th>100шт</th>",
                        "<th>1000шт</th>",
                      "<tr>",
                    "</thead>",
                    "<tbody>",
                      row,
                    "</tbody>",
                  "</table>",
                "</div>",
              "</dd>"
            ].join("")
          $("dl#search-result").append(html)
          if int == 1
            $('html, body').stop().animate({
              scrollTop: $('#ancor').offset().top
            }, 666);
            $("div#clear-fix").html("")

  else
    console.log "maxpage!"


root = exports ? this
root.counter  = makeCounter() 
root.maxpages = 1

$(document).ready ->
  $(window).scroll ->
    if $(window).scrollTop() is $(document).height() - $(window).height()
      loader(root.query, root.counter())


  $("form#search").submit((e) ->  
    e.preventDefault()
    root.query = $("input#main-query").val()
    if query != ""
      i = root.counter.reset()
      loader(root.query, i)
    else
      alert "Пустой запрос :("
  )