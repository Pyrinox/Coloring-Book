# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require underscore
#= require hammer
#= require paper-full

class window.ColoringInteraction
    @COLORING_PAGE: "/coloringpages/pusheen.svg"
    constructor: (options)->
        scope = this
        Utility.paperSetup "paperCanvas"
        # SETUP COLOR PALETTE
        window.cp = new ColorPalette
            container: $("#color-palette")
        # IMPORT COLORING PAGE
        # from = new Point(20, 20)
        # to = new Point(80, 80)
        
        # path = new (Path.Rectangle)(paper.view.center, 200)
        # path.strokeColor = 'black'
        # path.fillColor = 'red'
        # path.selected = true
        # paper.view.update();
        
        
        # uncomment line below to test myGradientInteraction()
        # scope.myGradientInteraction()
        
        # uncomment lines 32-37 to test myCustomInteraction()
        paper.project.importSVG ColoringInteraction.COLORING_PAGE, (svg)->
            svg.position = paper.view.center
            
            # COMMENT OUT ONE OF THESE TO TOGGLE BETWEEN INTERACTIONS
            # scope.myGradientInteraction()
            scope.myCustomInteraction()
            
    myGradientInteraction: ()->     
        console.log "IN GRADIENT"
        hitOptions = 
            segments: false
            stroke: false
            fill: true
            tolerance: 5
        # IMPLEMENT GRADIENT COLOR HERE
     
        path = new paper.Path.Rectangle
            position: paper.view.center
            size: [200, 200]
            
        path.strokeColor = 'black'
        path.fillColor = 'red'
        
        check_drag = false
        
        window.t = new paper.Tool
        t.myActivePath = null
        t.minDistance = 10
        origin = new Point
        t.onMouseDown =  (event)->
            origin = event.point
            hitResult = paper.project.hitTest(event.point, hitOptions)
            if not hitResult then return

            _.each hitResult, (hit)->
                # DON'T COLOR THE BLACK LINES
                if hit.fillColor and hit.fillColor.equals("black") then return;
                hit.fillColor = cp.currentColor()
                
                t.myActivePath = hit.items
        t.onMouseDrag =  (event)->
            # MOUSE DRAG ACTION
            check_drag = true
            
        t.onMouseUp =  (event)->
            destination = event.point
            # MOUSE UP ACTION
            r = new Color("red")
            console.log event.point, r.toCSS(), paper.view.center
            if check_drag == true
                path.fillColor = 
                    "gradient":
                        "stops": [cp.currentColor(), cp.lastColor()]
                        "radial": false
                    origin: origin
                    destination: destination
                check_drag = false
            
            
    myCustomInteraction: ()->     
        hitOptions = 
            segments: false
            stroke: false
            fill: true
            tolerance: 5
            
        # path = new paper.Path.Rectangle
        #     position: paper.view.center
        #     size: [200, 200]
        #     opacity: .5
        #     hue: 0
            
        # path.strokeColor = 'black'
        # path.fillColor = 'white'
        
        hitResult = null
        safeguard = false
        origin = new Point
        # IMPLEMENT GRADIENT COLOR HERE
        t = new paper.Tool
        t.minDistance = 10
        t.onMouseDown =  (event)->
            origin = event.point
            hitResult = paper.project.hitTest(event.point, hitOptions)
            console.log hitResult, "blaaaa"
            if not hitResult then return
            
            _.each hitResult, (hit)->
                # DON'T COLOR THE BLACK LINES
                if hit.fillColor and hit.fillColor.equals("black") then return;
                console.log hit.opacity, "hit.opacity"
            
                hit.fillColor = cp.currentColor()
                hit.opacity = .5
                hit.hue = 0
                safeguard = true

               
        t.onMouseDrag =  (event)->
            # MOUSE DRAG ACTION
            if safeguard
                destination = event.point
                hitResult = paper.project.hitTest(event.point, hitOptions)
                if not hitResult then return
                console.log hitResult, "LKASJDL"
                _.each hitResult, (hit)->
                    # DON'T COLOR THE BLACK LINES
                    console.log "here"
                    console.log hit.hue
                    
                    if hit.fillColor and hit.fillColor.equals("black") then return;
                    calc_y = origin.y - destination.y
                    y_holder = calc_y / 100
                    # console.log path.opacity
                    safeguard = false
                    if calc_y > 0 # mouse going up
                        if hit.opacity + y_holder >= 1.0
                            console.log "case1"
                            hit.opacity = 1
                            return 
                        # console.log "case1a"
                        hit.opacity += y_holder
                    else # mouse go down
                        if hit.opacity + y_holder <= 0.0 
                            # console.log "case2"
                            hit.opacity = 0
                            return
                        # console.log "case2a"
                        hit.opacity += y_holder
            
                    calc_x = origin.x - destination.x
                    x_holder = calc_x
                    if hit.fillColor
                        console.log hit.fillColor.hue, "fillColor.type"
                        if calc_x < 0 
                            # if path.hue + x_holder >= 1.0
                            #     console.log "case1"
                            #     path.opacity = 1
                            #     return 
                            console.log hit.fillColor
                            hit.fillColor.hue -= x_holder
                        else # mouse go down
                            # if path.opacity + x_holder <= 0.0 
                            #     console.log "case2"
                            #     path.opacity = 0
                            #     return
                            console.log hit.fillColor
                            hit.fillColor.hue -= x_holder
                safeguard = false
                
      
                
            
            
            
        t.onMouseUp =  (event)->
            # MOUSE UP ACTION        
         
    
    
# COLOR PALETTE OBJECT - NO NEED TO TOUCH
class window.ColorPalette
    @HUES: 32
    constructor: (options)->
        _.extend this, options
        @history = [new paper.Color("yellow"), new paper.Color("blue")]
        @init()
    init: ->
        scope = this
        hues = _.range(0, 360, 360/ColorPalette.HUES)
        hues = _.map hues, (hue)->
            h = new paper.Color "red"
            h.hue = hue
            return h
        hues = _.flatten [new paper.Color("white"), hues, new paper.Color("black")]
        _.each hues, (hue, i)->
            swatch = $("<span>").addClass("swatch").css("background", hue.toCSS())
                                .click ()->
                                    scope.history.push new paper.Color rgb2hex($(this).css('background'))
                                    $(this).addClass('active').siblings().removeClass('active')
            if i == 0 then $(this).addClass('active')
            scope.container.append(swatch)
    currentColor: ->
        return @history[@history.length - 1]
    lastColor: ->
        return @history[@history.length - 2]