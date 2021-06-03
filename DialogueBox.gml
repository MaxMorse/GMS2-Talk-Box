enum DialogueBoxState {
	Resting,
	Flipping,
	Filling,
	Opening,
	Closing,
	Closed
}

function DialogueBox(x, y, w, h, text) constructor {

	self.x = x;
	self.y = y;
	self.w = w;
	self.h = h;
	self.text = text;
	_state = DialogueBoxState.Opening;
	textLineBreaks = "";
	margin = new Rect(50,50,50,50);
	offsetY = 0;
	_previousOffsetY = 0;
	_nextOffsetY = 0;
	draw_set_font(Font1);
	rowHeight = string_height(text);
	pageFlipDuration = .25;
	_pageFlipElapsed = 0;
	_openDuration = 1;
	widthLerp = new LerpStruct(0, self.w, _openDuration);
	heightLerp = new LerpStruct(0, self.h, _openDuration);
	currentWidth = 0;
	currentHeight = 0;

	
	textRect = new Rect(	x - w * 0.5 + margin.left,
							y - h * 0.5 + margin.top,
							x + w * 0.5 - margin.right,
							y + h * 0.5 - margin.bottom);
	numRows = textRect.Height() / rowHeight;
	pageCount = 0;
	if (textRect.Height() % rowHeight != 0) numRows -= 1;
	
	
	#region Line Breaks
	var subString = "";
	for(i = 1; i < string_length(text); i++)
	{
		subString += string_char_at(text, i);
		//if substring is too long
		if (string_width(subString) > textRect.Width())
		{
			var index = string_last_pos(" ", subString);
			var count = string_length(subString) - index + 1;
			var lastWord = string_copy(subString, index + 1, count);
			var substringTruncated = string_delete(subString, index,count);
			textLineBreaks += substringTruncated + "\n";
			subString = lastWord; 
		}
	}
	#endregion
	displayedPage = 0;
	isPageFilled = [];
	var rowCount = string_count("\n", textLineBreaks);
	pageCount = ceil(rowCount / numRows);
	for (var i = 0; i < pageCount; i++)
	{
		isPageFilled[i] = false;	
	}

	Draw = function()
	{
		draw_sprite_stretched(sBox,0,x,y,currentWidth,currentHeight);
		if (_state != DialogueBoxState.Opening && _state != DialogueBoxState.Closing && _state != DialogueBoxState.Closed) DisplayCurrentRows();		
	}
	
	Step = function(step)
	{
		switch (_state) {
		    case DialogueBoxState.Opening: OpenBox(step); break;
			case DialogueBoxState.Filling: Fill(step); break;
			case DialogueBoxState.Flipping: FlipPage(step); break;
			case DialogueBoxState.Closing: CloseBox(step); break;
		}
		
	}
	
	Advance = function()
	{
		switch (_state) {
		    case DialogueBoxState.Resting:
		        if (displayedPage < pageCount - 1 )
				{
					InitPageFlip(offsetY - textRect.Height());
					displayedPage++;
				}
		        else if (displayedPage >= pageCount - 1 ) 
				{
					_state = DialogueBoxState.Closing;
				}
				break;
		}
		
	}
	Back = function()
	{
		switch (_state) {
		    case DialogueBoxState.Resting:
		        if (offsetY < 0)
				{ 
					InitPageFlip(offsetY + textRect.Height());
					displayedPage--;
				}
		        break;
		    default:
		        // code here
		        break;
		}
			
	}
	
	
	InitPageFlip = function(target)
	{
		_previousOffsetY = offsetY;
		_nextOffsetY = target;
		_pageFlipElapsed = 0;
		_state = DialogueBoxState.Flipping;
	}
	FlipPage = function(step)
	{
		
		_pageFlipElapsed += step;
		
		var amount =  _pageFlipElapsed/ pageFlipDuration;
		
		if (amount >= 1)
		{
			offsetY = _nextOffsetY;
			
			_state = DialogueBoxState.Resting;
		}
		else
		{
			
			offsetY = lerp(_previousOffsetY, _nextOffsetY, amount );
		}
	}
	OpenBox = function(step)
	{
		currentHeight = heightLerp.LerpOverTime(step);
		currentWidth = widthLerp.LerpOverTime(step);
		if (currentHeight >= h && currentWidth >= w )
		{
				_state = DialogueBoxState.Resting;
		}
		
	}
	CloseBox = function(step)
	{
		currentHeight = heightLerp.LerpOverTime(-step);
		currentWidth = widthLerp.LerpOverTime(-step);
		if (currentHeight <= 0 && currentWidth <= 0 )
		{
				_state = DialogueBoxState.Closed;
		}
		
	}
	
	Fill = function(step)
	{
		//TODO: To be implemented	
	}
	
	DisplayCurrentRows = function()
	{
		shader_set(DialogueBoxMask);
		var u_bounds = shader_get_uniform(DialogueBoxMask, "u_bounds");
		shader_set_uniform_f(u_bounds, textRect.left, textRect.top, textRect.right, textRect.bottom);
		
		draw_text(textRect.left, textRect.top + offsetY, textLineBreaks) 
		shader_reset();
	}

}
function LerpStruct(start, finish, duration) constructor
{
	_start = start;
	_finish = finish;
	_duration = duration;
	_elapsed = 0;
	
	LerpOverTime = function(step)
	{
		_elapsed += step;
		var amount = _elapsed / _duration
		if (amount >= 1)
		{
				value = _finish;
		}
		else
		{
			value = lerp(_start, _finish, amount);
		}
		return value;		
	}
	
}
    function Rect(left, top, right, bottom) constructor 
{
	self.left = left;
	self.top = top;
	self.right = right;
	self.bottom = bottom;
	
	Height = function(){ return bottom - top; }
	Width = function(){ return right - left; }
}
