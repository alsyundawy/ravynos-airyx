/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <AppKit/NSThemeFrame.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSWindow-Private.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSToolbarView.h>
#import <AppKit/NSAttributedString.h>
#import <Onyx2D/O2Context.h>

@implementation NSThemeFrame

-(BOOL)isOpaque {
   return YES;
}

-(NSWindowBorderType)windowBorderType {
   return _borderType;
}

-(void)setWindowBorderType:(NSWindowBorderType)borderType {
   _borderType = borderType;
   [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)rect {
    NSRect bounds = [NSWindow contentRectForFrameRect:[self bounds]
        styleMask:[[self window] styleMask]];
    //float cheatSheet = 0;

    [[[self window] backgroundColor] setFill];
    NSRectFill(bounds);
   
    switch(_borderType){
        case NSNoBorder:
            break;
            
        case NSWindowToolTipBorderType:
            [[NSColor blackColor] setStroke];
            NSFrameRect(bounds);
            bounds = NSInsetRect(bounds, 1, 1);
            //cheatSheet = 1;
            break;
                
        case NSWindowSheetBorderType:
            NSDrawButton(bounds,bounds);
            bounds = NSInsetRect(bounds, 2, 2);
            //cheatSheet = 2;
            break;
    }
#if 0
    if(([[self window] styleMask]  & 0x0FFF) == NSBorderlessWindowMask)
        return;
    
    if([[self window] isSheet])
        bounds.size.height += cheatSheet;

    O2Context *_context = [[self window] cgContext];
    O2ContextSetGrayStrokeColor(_context, 0.8, 1);
    O2ContextSetGrayFillColor(_context, 0.8, 1);

    // let's round these corners
    float radius = 12;
    O2ContextBeginPath(_context);
    O2ContextMoveToPoint(_context, _frame.origin.x+radius, NSMaxY(_frame));
    O2ContextAddArc(_context, _frame.origin.x + _frame.size.width - radius,
        _frame.origin.y + _frame.size.height - radius, radius, 1.5708 /*radians*/,
        0 /*radians*/, YES);
    O2ContextAddLineToPoint(_context, _frame.origin.x + _frame.size.width,
        _frame.origin.y);
    O2ContextAddArc(_context, _frame.origin.x + _frame.size.width - radius,
        _frame.origin.y + radius, radius, 6.28319 /*radians*/, 4.71239 /*radians*/,
        YES);
    O2ContextAddLineToPoint(_context, _frame.origin.x, _frame.origin.y);
    O2ContextAddArc(_context, _frame.origin.x + radius, _frame.origin.y + radius,
        radius, 4.71239, 3.14159, YES);
    O2ContextAddLineToPoint(_context, _frame.origin.x,
        _frame.origin.y + _frame.size.height);
    O2ContextAddArc(_context, _frame.origin.x + radius, _frame.origin.y +
        _frame.size.height - radius, radius, 3.14159, 1.5708, YES);
    O2ContextAddLineToPoint(_context, _frame.origin.x, NSMaxY(_frame));
    O2ContextClosePath(_context);
    O2ContextFillPath(_context);

    // window controls
    int diameter = 12;
    CGRect button = NSMakeRect(10, _frame.size.height - 21, diameter, diameter);
    _closeButtonRect = button;
    O2ContextSetRGBFillColor(_context, 1, 0, 0, 1);
    O2ContextFillEllipseInRect(_context, button);
    O2ContextSetRGBFillColor(_context, 1, 0.9, 0, 1);
    button.origin.x += 22;
    _miniButtonRect = button;
    O2ContextFillEllipseInRect(_context, button);
    O2ContextSetRGBFillColor(_context, 0, 1, 0, 1);
    button.origin.x += 22;
    _zoomButtonRect = button;
    O2ContextFillEllipseInRect(_context, button);

    // title
    NSString *t = [[self window] title];
    if(t) {
        NSDictionary *attrs = @{
            NSFontAttributeName : [NSFont titleBarFontOfSize:15.0],
            NSForegroundColorAttributeName : [NSColor darkGrayColor]
        };
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:t attributes:attrs];
        NSSize size = [title size];
        NSRect titleRect = NSMakeRect(
            _frame.size.width / 2 - size.width / 2,
            _frame.size.height - 30 + size.height / 2,
            _frame.size.width / 2 + size.width / 2,
            _frame.size.height - 4);
        [title drawInRect:titleRect];
    }

   [[[self window] backgroundColor] setFill];
   NSRectFill([[[self window] contentView] frame]);
#endif
}

-(void)resizeSubviewsWithOldSize:(NSSize)oldSize {
   NSToolbarView *toolbarView=nil;
   NSView *contentView=nil;
   
// tile the subviews, when/if we add titlebars and such do it here
   for(NSView *view in _subviews){
    if([view isKindOfClass:[NSToolbarView class]])
     toolbarView=(NSToolbarView *)view;
    else
     contentView=view;
   }
   
   NSRect toolbarFrame=(toolbarView!=nil)?[toolbarView frame]:NSZeroRect;
   NSRect contentFrame=[[[self window] class] contentRectForFrameRect:[self bounds] styleMask:[[self window] styleMask]];
   toolbarFrame.origin.y=NSMaxY(contentFrame)-toolbarFrame.size.height;
   toolbarFrame.origin.x=contentFrame.origin.x;
   toolbarFrame.size.width=contentFrame.size.width;
   
   [toolbarView setFrame:toolbarFrame];
   [toolbarView layoutViews];
   
   contentFrame.size.height-=toolbarFrame.size.height;
   [contentView setFrame:contentFrame];
}

-(void)mouseDown:(NSEvent *)event {
    if([[self window] isMovableByWindowBackground]) {
        [[self window] requestMove:event];
        return;
    }

    // is click in title bar?
    CGFloat top, left, right, bottom;
    CGNativeBorderFrameWidthsForStyle([[self window] styleMask], &top, &left, &bottom, &right);
    NSPoint pos = [event locationInWindow];

    // no - return.
    if(!(pos.y > (NSMaxY(_frame) - top)))
        return;

    // did they click a button?
    if(NSPointInRect(pos, _closeButtonRect))
        [[self window] performClose:self];
    else if(NSPointInRect(pos, _miniButtonRect))
        [[self window] performMiniaturize:self];
    else if(NSPointInRect(pos, _zoomButtonRect))
        [[self window] performZoom:self];
    else
        [[self window] requestMove:event];
}

@end
