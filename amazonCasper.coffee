lg = ->
  console.log.apply console, arguments
  return
fs = require("fs")
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

# # print out all the messages in the headless browser context
# casper.on "remote.message", (msg) ->
#   @echo "remote message caught: " + msg
#   return

resources = 0

casper.on "remote.message", (msg) ->
  @echo "remote message caught: " + msg
  return

# casper.on "resource.requested", (data,req)->
#   # @log "resource.requested: "+data.url
#   resources++
#   @log "resource.requested: "+resources
# casper.on "resource.received", (resource)->
#   # @log "resource.received: "+resource.url  
#   resources--
#   @log "resource.received: "+resources 


casper.on "page.error", (msg, trace) ->
  @echo "Page Error: " + msg, "ERROR"
  return
casper.on "page.log", (msg, trace) ->
  @echo "Page Log: " + msg, "ERROR"
  return

url = "http://www.amazon.com/gp/goldbox/all-deals/ref=sv_gb_1";

casper.start().thenOpen url, ->
  console.log "page loaded"
  # if @exists("a.UFIShareLink")
  #   lg " a.UFIShareLink exists"
  # else
  #   lg " a.UFIShareLink ling doesnt exist"  
  # return

casper.waitFor ->
  # @echo "waitfor"
  @evaluate ->
    ret=true
    lists = jQuery(".gbwshoveler-content ul")
    return false unless lists.length > 10
    true
, thn = ->
  null
, timeout = ->
  fs.write("the.html",this.getHTML())
, 15000

casper.then ->
  @evaluate ->
    window.preCategories =[]
    jQuery(".ONETHIRTYFIVE-HERO").each (id, el)->
      $el = jQuery(el)
      window.preCategories.push  
        $node: $el
        totalPages: parseInt $el.find(".gbwpagination span")[1].innerHTML
        shownPage: ->
          parseInt $el.find(".gbwpagination span")[0].innerHTML
        awaitingPage: 1
        savedPage: 0
        items: []
        finished: false
        title: $el.find(".gbh2cont h2").text()
        nextPage: ->
          $el.find(".next-button a").click()
casper.waitFor ->
  @evaluate ->
    ret=true
    window.preCategories.forEach (el,ind)->
      if el.savedPage < el.totalPages
        ret = false 
      else 
        return null 
      return null if el.$node.find("li.spinner > div > img").length > 0
        
      console.log("dbg1")
      if(el.awaitingPage > el.shownPage())
        return null
      console.log("dbg2")
      if(el.shownPage() > el.savedPage)        
        lis = el.$node.find("ul li")
        lis.each (id,li)->
          $li=jQuery(li)
          item =
            imageUrl: $li.find(".prodimg img").attr("src")
            linkUrl: $li.find(".title a").attr("href")
            description: $li.find(".title a").text()
            timeLeft: $li.find(".ldtimeleft > span").html()
          if(item.imageUrl and item.description and item.timeLeft and item.linkUrl)
            el.items.push item
          console.log "item pushed"
        el.savedPage++
        if el.savedPage < el.totalPages
          el.$node.find(".next-button a").click()
          el.awaitingPage++
    ret
, thn = ->
  null
, timeout = ->
  fs.write("the.html",this.getHTML())
, 40000
casper.then ->
  cats = @evaluate ->
    categories=[]
    window.preCategories.forEach (el,ind)->
      categories.push
        title: el.title
        items: el.items
    categories
  fs.write "out.json", JSON.stringify cats
# casper.then ->
#   fs.write("the.html",this.getHTML())
#   null
# , ->
#     lg "timed out"
# , 5000

casper.run()