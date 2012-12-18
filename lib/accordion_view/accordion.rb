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
    
    if(super)
      @views                      = []
      @headers                    = []
      @original_sizes             = []
      self.backgroundColor        = UIColor.clearColor
      self.userInteractionEnabled = true
      @animation_duration         = 0.3
      @animation_curve            = UIViewAnimationCurveEaseIn
      self.autoresizesSubviews    = false
      @selection_indexes          = NSIndexSet.new

      @scroll_view                        = UIScrollView.alloc.initWithFrame([[0, 0], [self.frame.size.width, self.frame.size.height]])
      @scroll_view.backgroundColor        = UIColor.clearColor
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
      @views                    << view
      @original_sizes           << NSValue.valueWithCGSize(view.frame.size)
      view.setAutoresizingMask(UIViewAutoresizingNone)
      view.setClipsToBounds(true)

      # modify the width of the header to the width of accordion
      frame = header.frame
      frame.origin.x = 0
      frame.size.width = self.frame.size.width
      header.setFrame(frame)
      # header.rounded_corners

      # modify the width of the body to the width of accordion
      frame = view.frame
      frame.origin.x = 0
      frame.size.width = self.frame.size.width
      view.setFrame(frame)
      # view.rounded_corners


      @scroll_view.addSubview(header)
      @scroll_view.addSubview(view)

      if(header.respondsToSelector("addTarget:action:forControlEvents:"))
        header.setTag(@headers.size - 1)
        header.addTarget(self, action:"touch_down:", forControlEvents:UIControlEventTouchUpInside)
      end

      set_selected_index(0) if(@selection_indexes.count == 0)

    end
  end

  def set_selection_indexes(_selection_indexes)
    return if(@headers.size == 0)

    if(not @allow_multiple_selection and _selection_indexes.count > 1)
      _selection_indexes = NSIndexSet.indexSetWithIndex(_selection_indexes.firstIndex)
    end

    clean_indexes = NSMutableIndexSet.new
    _selection_indexes.enumerateIndexesUsingBlock(lambda do |index, stop|
      return if(index > @headers.size-1)

      clean_indexes.addIndex(index)
    end)

    @selection_indexes = clean_indexes
    self.setNeedsLayout

    if(@delegate.respondsToSelector("accordion:didChangeSelection:"))
      @delegate.accordion(self, didChangeSelection:@selection_indexes)
    end

  end

  def set_selected_index(index)
    set_selection_indexes(NSIndexSet.indexSetWithIndex(index))
  end

  def selected_index
    @selection_indexes.first
  end

  def set_original_size(size, forIndex:index)
    return if(index >= @views.size)

    @original_sizes[index] = NSValue.valueWithCGSize(size)
    
    self.setNeedsLayout if(@selection_indexes.containsIndex(index))
  end

  def touch_down(sender)
    if(@allow_multiple_selection)
      temp_copy = @selection_indexes.mutableCopy

      if(@selection_indexes.containsIndex(sender.tag))
        temp_copy.removeIndex(sender.tag)
      else
        temp_copy.addIndex(sender.tag)
      end
      set_selection_indexes(temp_copy)
    else
      set_selected_index(sender.tag)
    end
  end

  def animation_done
    @views.each_with_index do |view, index|
      view.setHidden(true) unless(@selection_indexes.containsIndex(index))
    end
  end

  def layoutSubviews
    height = 0
    @views.each_with_index do |view, index|
      original_size = @original_sizes[index].CGSizeValue
      view_frame = @views[index].frame
      header_frame = @headers[index].frame
      header_frame.origin.y = height
      height += header_frame.size.height
      view_frame.origin.y = height

      if(@selection_indexes.containsIndex(index))
        view_frame.size.height = original_size.height
        @views[index].setFrame(CGRectMake(0, view_frame.origin.y, self.frame.size.width, 0))
        @views[index].setHidden(false)
      else
        view_frame.size.height = 0
      end

      height += view_frame.size.height

      if(not CGRectEqualToRect(@views[index].frame, view_frame) or not CGRectEqualToRect(@headers[index].frame, header_frame))
        UIView.beginAnimations(nil, context:nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector("animation_done:")
        UIView.setAnimationDuration(@animation_duration)
        UIView.setAnimationCurve(@animation_curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        @headers[index].setFrame(header_frame)
        @views[index].setFrame(view_frame)
        UIView.commitAnimations
      end

      offset = @scroll_view.contentOffset

      UIView.beginAnimations(nil, context:nil)
      UIView.setAnimationDuration(@animation_duration)
      UIView.setAnimationCurve(@animation_curve)
      UIView.setAnimationBeginsFromCurrentState(true)
      @scroll_view.setContentSize(CGSizeMake(self.frame.size.width, height))
      UIView.commitAnimations

      if(offset.y + @scroll_view.size.height > height)
        offset.y = height - @scroll_view.frame.size.height
        offset.y = 0 if(offset.y < 0)
      end
      
      @scroll_view.setContentOffset(offset, animated:true)
      self.scrollViewDidScroll(@scroll_view)
    end
  end

  def scrollViewDidScroll(_scroll_view)
    @views.each_with_index do |view, index|
      if(view.frame.size.height > 0)
        header = @headers[index]
        content = view.frame

        content.origin.y -= header.frame.size.height
        content.size.height += header.frame.size.height

        frame = header.frame

        if (CGRectContainsPoint(content, _scroll_view.contentOffset))
          if (_scroll_view.contentOffset.y < content.origin.y + content.size.height - frame.size.height)
            frame.origin.y = _scroll_view.contentOffset.y
          else
            frame.origin.y = content.origin.y + content.size.height - frame.size.height
          end
        else
          frame.origin.y = view.frame.origin.y - frame.size.height
        end
        header.frame = frame
      end
    end
  end

end