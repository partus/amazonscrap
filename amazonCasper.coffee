# run with --web-security=false 
lg = ->
  console.log.apply console, arguments
  return
casper = require("casper").create(
  verbose: true
  logLevel: "debug"
  pageSettings:
    loadImages:  false # The WebPage instance used by Casper will
    loadPlugins: false # use these settings
    # userAgent: "Mozilla/5.0 (X11; Linux x86_64; U; de; rv:1.9.1.6) Gecko/20091201 Firefox/3.5.6 Opera 10.62"
    userAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36"
  viewportSize: 
    width: 2000
    height: 2000
)
system = require('system')

url = "http://www.amazon.com/gp/goldbox/all-deals/ref=sv_gb_1";
# print out all the messages in the headless browser context
# casper.on "remote.message", (msg) ->
#   @echo "remote message caught: " + msg
#   return


casper.start().thenOpen url, ->
  null

casper.waitFor ->
  @evaluate ->
    lists = jQuery(".gbwshoveler-content ul")
    if lists.length > 10
      true
    else
      false
, thn = ->
  null
, timeout = ->
  null 
, 15000

casper.then ->
  @evaluate ->
    window.preCategories =[]
    jQuery(".ONETHIRTYFIVE-HERO").each (id, el)->
      $el = jQuery(@)
      window.preCategories.push  
        $node: $el
        totalPages: parseInt $el.find(".gbwpagination span")[1].innerHTML
        shownPage: ->
          parseInt @$node.find(".gbwpagination span")[0].innerHTML
        awaitingPage: 1
        savedPage: 0
        items: []
        finished: false
        title: $el.find(".gbh2cont h2").text()?.trim()
        nextPage: ->
          @$node.find(".next-button a").click()
      true
casper.waitFor ->
  @evaluate ->
    do ->
      ret=true
      window.preCategories.forEach (el,ind)->
        if el.savedPage < el.totalPages
          ret = false 
        else 
          return null 
        if el.$node.find("li.spinner > div > img").length > 0
          # console.log "spining total:#{el.totalPages};saved:#{el.savedPage};awaiing:#{el.awaitingPage}"
          return null 
        if(el.awaitingPage > el.shownPage())
          return null
        if(el.shownPage() > el.savedPage)        
          lis = el.$node.find("ul li")
          lis.each (id,li)->
            $li=jQuery(@)
            item =
              imageUrl: $li.find(".prodimg img").attr("src")
              linkUrl: $li.find(".title a")[0]?.href
              description: $li.find(".title a").text()?.trim()
              timeLeft: $li.find(".ldtimeleft > span").text()
            if(item.imageUrl and item.description and item.timeLeft and item.linkUrl)
              el.items.push item
            true
          el.savedPage++
          if el.savedPage < el.totalPages
            el.$node.find(".next-button a").click()
            el.awaitingPage++
      ret
, thn = ->
  null
, timeout = ->
  @log "Timeout scraping page"
  casper.exit()
, 70000
casper.then ->
  cats = @evaluate ->
    categories=[]
    window.preCategories.forEach (el,ind)->
      categories.push
        title: el.title
        items: el.items
    # categories.forEach (el,ind)->
    # jQuery.ajax
    #   type: "POST"
    #   url: "http://localhost:3000/"
    #   data: JSON.stringify categories 
    #   success: ->
    #     console.log "success", arguments
    #   async: false
    categories
  self = @
  # cats.forEach (el,ind)->
  #   self.open "http://localhost:3000/",{method: "post", data: JSON.stringify el }
  self.open "http://localhost:#{system.env.PORT or 5000}/",{method: "post", data: {all: JSON.stringify cats} }, ->
    @echo "post done"
  # @echo JSON.stringify cats
casper.run()


lg "http://localhost:#{system.env.PORT or 5000}/"