class Accordion < UIView

  attr_accessor :views, :headers, :original_sizes, :scroll_view

  attr_accessor :selected_index

  attr_accessor :animation_duration

  attr_accessor :animation_curve

  attr_accessor :allow_multiple_selection

  # Set of selected inddxes for multiple selection
  attr_accessor :selection_indexes

  attr_accessor :delegate


  def initWithFrame(frame) 
    
    if(super.initWithFrame(frame))
      @views                      = []
      @headers                    = []
      @original_sizes             = []
      self.backgroundColor        = UIColor.clearColor
      self.userInteractionEnabled = true
      @animation_duration         = 0.3
      @animation_curve            = UIViewAnimationCurveEaseIn
      self.autoresizesSubviews    = false
      @selection_indexes          = []

      @scroll_view                        = UIScrollView.alloc.initWithFrame([[0, 0], [self.frame.size.with, self.frame.size.height]])
      @scroll_view                        = UIColor.clearColor
      @scroll_view.userInteractionEnabled = true
      @scroll_view.autoresizesSubviews    = false
      @scroll_view.scrollsToTop           = false
      @scroll_view.delegate               = self

      addSubview(@scroll_view)

      @allow_multiple_selection = false

    end

    self
  end


  def add_header(header, withView:view)
    if(header and view)
      
      @headers                  << header
      @view                     << view
      @original_sizes           << NSValue.valueWithCGSize(view.frame.size)
      view.setAutoresizingMask  = UIViewAutoresizingNone
      view.setClipsToBounds     = true

      # modify the width of the header to the width of accordion
      frame = header.frame
      frame.origin.x = 0
      frame.size.width = self.frame.size.width
      header.setFrame(frame)

      # modify the width of the body to the width of accordion
      frame = view.frame
      frame.origin.x = 0
      frame.size.width = self.frame.size.width
      view.setFrame(frame)


      @scroll_view.addSubview(header)
      @scroll_view.addSubview(view)

      if(header.respondsToSelector("addTarget:action:forControlEvents:"))
        header.setTag(@headers.size - 1)
        header.addTarget(self, action:"touchDown:", forControlEvents:UIControlEventTouchUpInside)
      end

      @selected_index = 0 if(@selection_indexes.size == 0)

    end
  end

end