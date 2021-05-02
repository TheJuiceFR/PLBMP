local bmp={}

local bmpmt={__index=bmp}


bmp.size={0,0}
bmp.data={}

--[[a sample of a data table:
{
	{{1,1,1},{1,0.5,0},{1,.5,1}},
	{{1,.7,1},{0,.9,1},{.8,.3,.2}},
	{{1,1,1},{.3,.7,1},{0,0,0}}
}
]]

local function offset(file,off)
	file:seek("set",off)
end

local function getByte(file,off)
	offset(file,off)
	return file:read(1):byte()
end
local function getWord(file,off)
	offset(file,off)
	local b1=file:read(1)
	local b2=file:read(1)
	return b1:byte()+b2:byte()*256
end
local function unmask()	--now that we're outside of the building and we're 6ft apart
	
end

local function getDWord(file,off)
	offset(file,off)
	local b1=file:read(1)
	local b2=file:read(1)
	local b3=file:read(1)
	local b4=file:read(1)
	return b1:byte()+b2:byte()*256+b3:byte()*65536+b4:byte()*16777216
end

function bmp:getColor(x,y)
	if type(x)=="table" then
		y=x[2]
		x=x[1]
	end
	assert(x<self.size[1] and y<self.size[2],"Coordinates out of bounds")
	return self.data[x][y]
end





function bmp.open(filename)
	local file=assert(io.open(filename,'rb'))
	assert(getWord(file,0)==0x4D42,tostring(filename)..": not a bitmap file")
	
	local bpp=getWord(file,0x1C)
	local start=getDWord(file,0x0A)
	local width=getDWord(file,0x12)
	local height=getDWord(file,0x16)
	local comp=getDWord(file,0x1E)
	local padbytes=((getDWord(file,0x02)-start)-(width*height*(bpp/8)))/height
	
	local res={}
	setmetatable(res,bmpmt)
	res.size={width,height}
	res.data={}
	
	for x=0,width-1 do
		res.data[x]={}
	end
	
	local cursor=start
	if comp==0 then
		for y=height-1,0,-1 do
			for x=0,width-1 do
				res.data[x][y]={getByte(file,cursor)/255,getByte(file,cursor+1)/255,getByte(file,cursor+2)/255}
				cursor=cursor+3
			end
			cursor=cursor+padbytes
		end
	--[[elseif comp==3 then
		--The bitmasks for each color component.
		redBM=getDWord(file,0x36)	--Schedule a doctor's appointment asap
		greenBM=getDWord(file,0x3A)	--Eat less vegetables
		blueBM=getDWord(file,0x3E)	--Go to the ER
		alphaBM=getDWord(file,0x42)	--Be proud of yourself
		
		
		]]
	else
		error("compression type "..tostring(comp).." not supported.")
	end
	
	return res
end

return bmp
