--!strict

type TweenProps = {
  instance: Instance,
  info: TweenInfo,
  properties: Dictionary<any>,
};

type LibraryProps = {
  title: string,
  custom_codes: table?,
}

type PageProps = {
  library: table?,
  title: string
}

local library = {};
local page = {};
local inputEnded = {};
local Debug = {
  log = {}
}

local library_codes = {
  MODULE_UNKNOWN_TITLE = "Unknown",
  MODULE_UNKNOWN_DESCRIPTION = "There is no description of this module."
}

function Debug:addLog(msg: string)
  -- table.insert(Debug.log, string.format("DEBUG: %s", msg));
end

library.__index = library;
page.__index = page;

local TweenService = game:GetService("TweenService");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local Mouse = game.Players.LocalPlayer:GetMouse();

local _Color3 = Color3.fromRGB;
local UDim2 = UDim2.new;
local UDim = UDim.new;
local Vector2 = Vector2.new;

local themes = {
  ModuleBackground = _Color3(30, 30, 30),
  MoudleBorderColor = _Color3(25, 25, 25),
};

function Tween(data: TweenProps): Tween
  local obj = TweenService:Create(data.instance, data.info, data.properties);
  obj:Play();
  return obj;
end

function Draggable(frame: Instance, parent: Instance)
  parent = parent or frame

  local dragging = false
  local dragInput, mousePos, framePos

  frame.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
          dragging = true
          mousePos = input.Position
          framePos = parent.Position

          input.Changed:Connect(function()
          if input.UserInputState == Enum.UserInputState.End then
              dragging = false
          end
          end)
      end
  end)

  frame.InputChanged:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseMovement then
          dragInput = input
      end
  end)

  UserInputService.InputChanged:Connect(function(input)
      if input == dragInput and dragging then
          local delta = input.Position - mousePos
          parent.Position  = UDim2(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
      end
  end)
end

function CreateInstance(instance: string, properties: table, child)
  local Instance = Instance.new(instance);

  for i,v in pairs (properties or {}) do
     Instance[i] = v
  end

  for i,v in pairs (child or {}) do
     v.Parent = Instance
  end

  if (instance == "TextButton") then Instance.AutoButtonColor = false end;

  return Instance
end

function DraggingEnded(callback)
  table.insert(inputEnded, callback);
end

function HsvToRgb(h,s,v)
  local r,g,b,i,f,p,q,t;

  i = math.floor(h * 6)
  f = h * 6 - i
  p = v * (1 - s)
  q = v * ( 1 - f * s)
  t = v * (1 - (1 - f) * s)

  local newI = i % 6

  if (newI == 0) then
     r = v
     g = t
     b = p
  elseif newI == 1 then
     r = q
     g = v
     b = p
  elseif newI == 2 then
     r = p
     g = v
     b = t
  elseif newI == 3 then
     r = p
     g = q
     b = v
  elseif newI == 4 then
     r = t
     g = p
     b = v
  elseif newI == 5 then
     r = v
     g = p
     b = q
  end

  return {
     r = math.round(r * 255),
     g = math.round(g * 255),
     b = math.round(b * 255)
  }
end

function map(t: table, callback)
  for i,v in pairs (t) do
    local resp = callback(v, i);
    if (not resp) then
      table.remove(t, i);
    else
      t[i] = resp;
    end
  end

  return t;
end

function createShadow(parent, color: Color3)
  return CreateInstance("ImageLabel", {
    Parent = parent,
    BackgroundTransparency = 1.000,
    BorderSizePixel = 0,
    Position = UDim2(0, -15, 0, -15),
    Size = UDim2(1, 30, 1, 30),
    Image = "rbxassetid://5028857084",
    ImageColor3 = color or _Color3(16, 16, 16),
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Name = "shadow",
  });
end

function removeShadow(parent)
  for _,v in pairs (parent:GetChildren()) do
    if (v.Name == "shadow") then v:Destroy() end
  end
end

function sort(t, pattern)
  if (pattern == "" or #t == 0) then
    return t;
  end

  local result = {};

  for _, v in pairs (t) do
    if (string.find(string.lower(v), string.lower(pattern))) then
      table.insert(result, v);
    end
  end

  return result;
end

function library.new(data: LibraryProps)
  local ScreenGui = CreateInstance("ScreenGui", {
    Name = "TSLibrary",
    Parent = game:GetService("CoreGui")
  }, {
    CreateInstance("Frame", {
      Name = "Container",
      AnchorPoint = Vector2(0.5, 0.5),
      BackgroundColor3 = _Color3(30, 30, 30),
      BorderSizePixel = 0,
      Position = UDim2(0.5, 0, 0.5, 0),
      Size = UDim2(0, 700, 0, 500),
    }, {
     CreateInstance("UICorner"),
     CreateInstance("ScrollingFrame", {
       Name = "Navigation",
       BackgroundColor3 = _Color3(35, 35, 35),
       BorderSizePixel = 0,
       Position = UDim2(0, 0, 0.2, 5),
       Size = UDim2(0.25, 0, 0.800000012, -5),
       ScrollBarThickness = 0,
       CanvasSize = UDim2(0, 0, 0, 0)
     }, {
       CreateInstance("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim(0, 5)
       }),
       CreateInstance("UICorner"),
       CreateInstance("UIPadding", { PaddingTop = UDim(0, 10) })
     }),
     CreateInstance("Frame", {
       Name = "Header",
       BackgroundColor3 = _Color3(40, 40, 40),
       BorderSizePixel = 0,
       Size = UDim2(0.25, 0, 0.2, 0)
     }, {
       CreateInstance("TextLabel", {
         Name = "Title",
         AnchorPoint = Vector2(0.5, 0.5),
         BackgroundTransparency = 1,
         Position = UDim2(0.5, 0, 0.5, 0),
         Size = UDim2(1, -20, 0, 35),
         Font = Enum.Font.GothamSemibold,
         Text = data.title or "Unknown",
         TextColor3 = _Color3(255, 255, 255),
         TextSize = 16,
         TextXAlignment = Enum.TextXAlignment.Left
       }),
       CreateInstance("UICorner", { CornerRadius = UDim(0, 5) })
     })
    })
  });

  local Container: Frame = ScreenGui.Container;
  local Navigation: ScrollingFrame = Container.Navigation;
  local Header = Container.Header;

  -- Make Draggable
  createShadow(Container);
  Draggable(Header, Container);

  -- input init.

  UserInputService.InputEnded:Connect(function(key)
      if (key.UserInputType == Enum.UserInputType.MouseButton1) then
          for _,v in pairs(inputEnded) do
              v();
          end
      end
  end)

  if (typeof(data.custom_codes) == "table") then
    library_codes = {
      unpack(library_codes),
      unpack(data.custom_codes)
    };
  end

  return setmetatable({
    Navigation = Navigation,
    Header = Header,
    ScreenGui = ScreenGui,
    Container = Container,
    pages = {},
  }, library);
end

function page.new(data: PageProps)
  local pageButton = CreateInstance("TextButton", {
    BackgroundColor3 = _Color3(25, 25, 25),
    Size = UDim2(1, -20, 0, 30),
    Font = Enum.Font.SourceSansBold,
    Text = data.title or "Unknown",
    TextColor3 = _Color3(255, 255, 255),
    TextSize = 14,
    Parent = data.library.Navigation,
  }, {
    CreateInstance("UICorner", { CornerRadius = UDim(0, 5) })
  })

  local body = CreateInstance("ScrollingFrame", {
    Name = "Body",
    BackgroundColor3 = _Color3(35, 35, 35),
    BorderColor3 = _Color3(30, 30, 30),
    Position = UDim2(0.25, 5, 0, 5),
    Size = UDim2(0.75, -10, 0, 0),
    CanvasSize = UDim2(0, 0, 0, 0),
    ScrollBarThickness = 3,
    Parent = data.library.Container,
    Visible = false,
  }, {
    CreateInstance("UICorner"),
    CreateInstance("UIListLayout", {
     HorizontalAlignment = Enum.HorizontalAlignment.Center,
     Padding = UDim(0, 10)
    }),
    CreateInstance("UIPadding", { PaddingTop = UDim(0, 5), PaddingBottom = UDim(0, 5) })
  });

  return setmetatable({
    page = body,
    button = pageButton,
    modules = {},
    library = data.library
  }, page);
end

function library:addPage(data: PageProps)
  data.library = self;
  local page = page.new(data);
  local button: TextButton = page.button;

  table.insert(self.pages, page);

  button.MouseButton1Up:Connect(function()
    self:selectPage(page, true);
  end)

  return page;
end

function library:selectPage(page, enable: boolean)
  local FocusedPage = self.FocusedPage;

  if (FocusedPage == page and enable) then
    return Debug:addLog("Already Focused Page.");
  end

  if (enable) then
    self.FocusedPage = page;

    if (FocusedPage) then

      -- Wait until previous tab's animation.
      local co = coroutine.create(function()
        self:selectPage(FocusedPage, false);
      end)
      coroutine.resume(co);

      repeat
        coroutine.yield();
      until coroutine.status(co) == "dead";
    end

    page.page.Visible = true;
    Tween({
      instance = page.button,
      info = TweenInfo.new(0.2),
      properties = {
        BackgroundColor3 = _Color3(220, 220, 220),
        TextColor3 = _Color3(10, 10, 10),
      }
    }).Completed:Connect(function()
      Tween({
        instance = page.page,
        properties = {
          Size = UDim2(0.75, -10, 1, -10)
        },
        info = TweenInfo.new(0.2)
      }).Completed:Connect(function()
        -- resize
        page:Resize(true);
      end)
    end)

  else
    Tween({
      instance = page.button,
      info = TweenInfo.new(0.2),
      properties = {
        BackgroundColor3 = _Color3(25, 25, 25),
        TextColor3 = _Color3(255, 255, 255),
      }
    }).Completed:Connect(function()
      self.lastPosition = page.page.CanvasPosition.Y;
      Tween({
        instance = page.page,
        info = TweenInfo.new(0.2),
        properties = {
          Size = UDim2(0.75, -10, 0, 0),
        }
      }).Completed:Connect(function()
        -- resize
        page:Resize(false);
      end)
    end)
  end
end

function page:Resize(doScroll: boolean, padding: number?)
  local size = self.page.UIListLayout.AbsoluteContentSize.Y + (padding or 0);
  self.page.CanvasSize = UDim2(0, 0, 0, size);

  if (doScroll and self.lastPosition) then
    Tween({
      instance = self.page,
      properties = {
        CanvasPosition = self.lastPosition,
      },
      info = TweenInfo.new(0.2)
    });
  end
end

function page:createModuleHeader(data, properties: table)
  local Style = {
    BackgroundTransparency = 1,
    Size = UDim2(1, 0, 1, 0),
    unpack(properties or {})
  };

  return CreateInstance("Frame", Style, {
    CreateInstance("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2(1, 0, 0, 25),
      Font = Enum.Font.SourceSansBold,
      Text = data.title or library_codes.MODULE_UNKNOWN_TITLE,
      TextColor3 = _Color3(255, 255, 255),
      TextSize = 17.000,
      TextXAlignment = Enum.TextXAlignment.Left,
    }),
    CreateInstance("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2(1, 0, 0, 30),
      Font = Enum.Font.SourceSans,
      Text = data.description or library_codes.MODULE_UNKNOWN_DESCRIPTIONN,
      TextColor3 = _Color3(140, 140, 140),
      TextSize = 14,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
    }),
    CreateInstance("UIListLayout"),
    CreateInstance("UIPadding", { PaddingLeft = UDim(0, 5), PaddingRight = UDim(0, 5) })
  });
end

-- component types
type ButtonType = {
  title: string?;
  desc: string?;
  callback: any?;
  buttonText: string?;
};
type ToggleType = {
  title: string?;
  desc: string?;
  callback: any?;
  default: boolean?;
}
type DropdownType = {
  title: string?;
  desc: string?;
  callback: any?;
  list: table;
};
type SliderType = {
  title: string?;
  desc: string?;
  callback: any?;
  default: number?;
  min: number;
  max: number;
}
type ColorpickerType = {
  title: string?;
  desc: string?;
  callback: any?;
  default: Color3?;
};

function page:addButton(data: ButtonType)
  local callback = typeof(data.callback) == "function" and data.callback or function()
    Debug:addLog("Button Clicked.");
  end
  local page = self.page;

  if (not page) then
    return Debug:addLog("Button add event from unknown source.");
  end

  local button = CreateInstance("Frame", {
    Parent = page,
    BackgroundColor3 = themes.ModuleBackground,
    BorderSizePixel = 1,
    BorderColor3 = themes.MoudleBorderColor,
    Size = UDim2(1, -60, 0, 90),
    SizeConstraint = Enum.SizeConstraint.RelativeXX,
  }, {
    CreateInstance("TextButton", {
      AnchorPoint = Vector2(0.5, 0.5),
      BackgroundColor3 = _Color3(45, 45, 45),
      BorderSizePixel = 0,
      Position = UDim2(0.5, 0, 0.75, 0),
      Size = UDim2(0.9, 0, 0, 30),
      Font = Enum.Font.SourceSansBold,
      Text = data.buttonText or "Execute",
      TextColor3 = _Color3(255, 255, 255),
      TextSize = 15,
    }, {
      CreateInstance("UICorner", { CornerRadius = UDim(0, 5) })
    }),
    self:createModuleHeader({
      title = data.title,
      description = data.desc
    })
  });

  local textbutton: TextButton = button.TextButton;

  textbutton.MouseButton1Down:Connect(function()
    textbutton.BackgroundColor3 = _Color3(55, 55, 55);
  end)

  textbutton.MouseButton1Up:Connect(function()
    textbutton.BackgroundColor3 = _Color3(45, 45, 45);
    callback();
  end)
end

function page:addToggle(data: ToggleType)
  local callback = typeof(data.callback) == "function" and data.callback or function(value) end;
  local state = data.default or false;

  local toggle = CreateInstance("Frame", {
    Parent = self.page,
    BackgroundColor3 = themes.ModuleBackground,
    BorderSizePixel = 1,
    BorderColor3 = themes.MoudleBorderColor,
    Size = UDim2(1, -60, 0, 60),
  }, {
    self:createModuleHeader({
      title = data.title,
      description = data.desc,
    }, {
      Size = UDim2(0.7, 0, 1, 0),
    }),
    CreateInstance("TextButton", {
      AnchorPoint = Vector2(0.5, 0.5),
      BackgroundColor3 = _Color3(80, 80, 80),
      BorderSizePixel = 0,
      Position = UDim2(0.9, 0, 0.5, 0),
      Size = UDim2(0, 50, 0, 20),
      Text = "",
    }, {
      CreateInstance("UICorner", { CornerRadius = UDim(1, 0) }),
      CreateInstance("UIPadding", { PaddingBottom = UDim(0, 3), PaddingTop = UDim(0, 3), PaddingLeft = UDim(0, 2), PaddingRight = UDim(0, 2) }),
      CreateInstance("Frame", {
        AnchorPoint = Vector2(0, 0.5),
        BackgroundColor3 = _Color3(255, 255, 255),
        Position = UDim2(0, 0, 0.5, 0),
        Size = UDim2(0, 20, 0, 20),
      }, {
        CreateInstance("UICorner", { CornerRadius = UDim(1, 0) })
      })
    })
  });
  local toggleButton: TextButton = toggle.TextButton;
  local Ball: Frame = toggleButton.Frame;

  toggleButton.MouseButton1Down:Connect(function()
    Tween({
      instance = Ball,
      info = TweenInfo.new(0.2),
      properties = {
        Size = UDim2(0.7, 0, 0, 20),
        Position = state and UDim2(0.3, 0, 0.5, 0) or UDim2(0, 0, 0.5, 0),
      }
    });
  end)

  toggleButton.MouseLeave:Connect(function()
    if (Ball.Size == UDim2(0.7, 0, 0, 20)) then
      Tween({
        instance = Ball,
        info = TweenInfo.new(0.2),
        properties = {
          Size = UDim2(0, 20, 0, 20),
          Position = not state and UDim2(0, 0, 0.5, 0) or UDim2(1, -20, 0.5, 0),
        }
      })
    end
  end)

  toggleButton.MouseButton1Up:Connect(function()
    self:updateToggle(toggle, not state);
    callback(not state);
    state = not state;
  end)

  self:updateToggle(toggle, state);
end

function page:updateToggle(toggleInstance: Frame, state: boolean)
  if (toggleInstance) then
    local Ball: Frame = toggleInstance.TextButton.Frame;

    Tween({
      instance = Ball,
      info = TweenInfo.new(0.2),
      properties = {
        Size = UDim2(0, 20, 0, 20),
        Position = state and UDim2(1, -20, 0.5, 0) or UDim2(0, 0, 0.5, 0),
      }
    });
  end
end

function page:addDropdown(data: DropdownType)
  local callback = typeof(data.callback) == "function" and data.callback or function (value: string) end;
  local list = typeof(data.list) == "table" and data.list or {};

  local dropdown = CreateInstance("Frame", {
    Parent = self.page,
    BackgroundColor3 = themes.ModuleBackground,
    BorderSizePixel = 1,
    ClipsDescendants = true,
    Size = UDim2(1, -60, 0, 90),
    BorderColor3 = themes.MoudleBorderColor
  }, {
    CreateInstance("Frame", {
      Name = "Inner",
      BackgroundTransparency = 1,
      Size = UDim2(1, 0, 0, 90),
    }, {
      self:createModuleHeader({title = data.title, description = data.desc}),
      CreateInstance("Frame", {
        AnchorPoint = Vector2(0.5, 0),
        BorderSizePixel = 0,
        Size = UDim2(0.9, 0, 0, 30),
        Position = UDim2(0.5, 0, 0.5, 0),
        Name = "f",
        BackgroundColor3 = _Color3(45, 45, 45),
      }, {
        CreateInstance("TextBox", {
          BackgroundColor3 = _Color3(45, 45, 45),
          BorderSizePixel = 0,
          Size = UDim2(0.9, 0, 1, 0),
          Font = Enum.Font.Arial,
          Text = "",
          TextColor3 = _Color3(255, 255, 255),
          TextSize = 14,
          TextXAlignment = Enum.TextXAlignment.Left,
        }, {
          CreateInstance("UICorner", { CornerRadius = UDim(0, 5) }),
          CreateInstance("UIPadding", { PaddingLeft = UDim(0, 5), PaddingRight = UDim(0, 5) })
        }),
        CreateInstance("ImageButton", {
          AnchorPoint = Vector2(0, 0.5),
          BackgroundTransparency = 1,
          Position = UDim2(0.9, 5, 0.5, 0),
          Size = UDim2(0, 30, 0, 30),
          Image = "rbxassetid://5012539403",
        }),
        CreateInstance("Frame", {
          BackgroundColor3 = _Color3(35, 35, 35),
          BorderSizePixel = 0,
          Position = UDim2(0.9, 0, 0, 0),
          Size = UDim2(0, 1, 1, 0)
        }),
        CreateInstance("UICorner", { CornerRadius = UDim(0, 5) })
      }),
    }),
    CreateInstance("ScrollingFrame", {
      BackgroundColor3 = _Color3(45, 45, 45),
      BorderSizePixel = 0,
      Position = UDim2(0, 0, 0, 90),
      Size = UDim2(1, 0, 0, 250),
      CanvasSize = UDim2(0, 0, 0, 0),
      ScrollBarThickness = 2
    }, {
      CreateInstance("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim(0, 3),
      }),
      CreateInstance("UIPadding", { PaddingTop = UDim(0, 10) })
    })
  });

  local openButton: ImageButton = dropdown.Inner.f.ImageButton;
  local textbox: TextBox = dropdown.Inner.f.TextBox;

  textbox.Changed:Connect(function(prop)
    if (prop == "Text") then
      self:updateDropdown(dropdown, sort(data.list, textbox.Text), callback);
    end
  end)

  openButton.MouseButton1Click:Connect(function()
    if (openButton.Rotation == 180) then
      self:updateDropdown(dropdown, nil, callback);
    else
      self:updateDropdown(dropdown, list, callback);
    end
  end)

  dropdown:GetPropertyChangedSignal("Size"):Connect(function()
    self:Resize(false);
  end)
end

function page:updateDropdown(dropdownInstance: Frame, list, callback)
  if (dropdownInstance) then
    local itemList: ScrollingFrame = dropdownInstance.ScrollingFrame;
    local openButton: ImageButton = dropdownInstance.Inner.f.ImageButton;

    for _, Value in pairs (itemList:GetChildren()) do
      if (Value:IsA('TextButton')) then
        Value:Destroy();
      end
    end

    for _, Value in pairs (list or {}) do
      local button: TextButton = CreateInstance("TextButton", {
        BackgroundColor3 = _Color3(35, 35, 35),
        Size = UDim2(0.9, 0, 0, 30),
        Font = Enum.Font.SourceSansSemibold,
        Text = Value or "Dropdown Item",
        TextColor3 = _Color3(255, 255, 255),
        TextSize = 16,
        Parent = itemList,
        BorderSizePixel = 0,
      });

      button.MouseButton1Down:Connect(function()
        createShadow(button);
      end)

      button.MouseLeave:Connect(function()
        removeShadow(button)
      end);

      button.MouseButton1Up:Connect(function()
        removeShadow(button)
        callback(Value);
        self:updateDropdown(dropdownInstance, nil, callback);
      end)
    end

    itemList.CanvasSize = UDim2(0, 0, 0, itemList.UIListLayout.AbsoluteContentSize.Y);

    Tween({
      instance = dropdownInstance,
      info = TweenInfo.new(0.2),
      properties = {
        Size = UDim2(1, -60, 0, list and 340 or 90),
      }
    });
    Tween({
      instance = openButton,
      info = TweenInfo.new(0.2),
      properties = {
        Rotation = list and 180 or 0,
      }
    });
  end
end

function page:addSlider(data: SliderType)
  local callback = typeof(data.callback) == "function" and data.callback or function (v)end;
  local min, max, default = typeof(data.min) == "number" and data.min or 0, typeof(data.max) == "number" and data.max or 10, typeof(data.default) == "number" and data.default or 0;

  local slider = CreateInstance("Frame", {
    Parent = self.page,
    BackgroundColor3 = themes.ModuleBackground,
    BorderSizePixel = 1,
    Size = UDim2(1, -60, 0, 90),
    BorderColor3 = themes.MoudleBorderColor
  }, {
    self:createModuleHeader({ title = data.title, description = data.desc }),
    CreateInstance("TextButton", {
      AnchorPoint = Vector2(0.5, 0),
      BackgroundColor3 = _Color3(45, 45, 45),
      Position = UDim2(0.5, 0, 0.75, 0),
      Size = UDim2(1, -20, 0, 15),
      Text = "",
    }, {
      CreateInstance("UICorner", { CornerRadius = UDim(0, 5) }),
      CreateInstance("Frame", {
        BackgroundColor3 = _Color3(35, 35, 35),
        BorderSizePixel = 0,
        Size = UDim2(0, 0, 1, 0),
      }, {
        CreateInstance("UICorner", { CornerRadius = UDim(0, 5) }),
      })
    })
  });

  local sliderbutton: TextButton = slider.TextButton;
  local dragging = false;
  local value = default or min;

  self:updateSlider(slider, value, min, max);

  DraggingEnded(function()
    dragging = false;
  end)

  sliderbutton.MouseButton1Down:Connect(function()
    dragging = true;
    while dragging do
        callback(math.clamp(self:updateSlider(slider, nil, min , max), min, max));
        RunService.RenderStepped:Wait();
    end
  end)
end

function page:updateSlider(sliderInstance: Frame, value, min, max)
  if (sliderInstance) then
    local sliderbutton: TextButton = sliderInstance.TextButton;
    local percentage = ( Mouse.X - sliderbutton.AbsolutePosition.X ) / sliderbutton.AbsoluteSize.X;

    if (value) then
        percentage = (value - min) / (max - min);
    end

    percentage = math.clamp(percentage, 0, 1);
    value = value or math.floor(min + (max-min) * percentage);

    Tween({
      instance = sliderbutton.Frame,
      info = TweenInfo.new(0.05),
      properties = {
        Size = UDim2(percentage, 0, 1, 0)
      }
    })

    return value;
  end
end

function page:addColorpicker(data: ColorpickerType)
  self.library.popups = self.library.popups or {};
  local popups = self.library.popups;
  local callback = typeof(data.callback) and data.callback or function (v) end;
  local active = false;

  local colorpicker = CreateInstance("Frame", {
    BackgroundColor3 = themes.ModuleBackground,
    BorderSizePixel = 1,
    BorderColor3 = themes.MoudleBorderColor,
    Parent = self.page,
    Size = UDim2(1, -60, 0, 60),
  }, {
    self:createModuleHeader({ title = data.title, description = data.desc }, {
      Size = UDim2(0.7, 0, 1, 0)
    }),
    CreateInstance("TextButton", {
      AnchorPoint = Vector2(0, 0.5),
      BackgroundColor3 = data.default or _Color3(255, 255, 255),
      Position = UDim2(0.9, 0, 0.5, 0),
      Size = UDim2(0, 35, 0, 35),
      Text = "",
    }, {
      CreateInstance("UICorner", { CornerRadius = UDim(0, 9) }),
    })
  });

  local popupParent: ScreenGui = self.library.ScreenGui;
  local openButton: TextButton = colorpicker.TextButton;

  openButton.MouseButton1Down:Connect(function()
    --todo: animate
  end)

  openButton.MouseButton1Up:Connect(function()
    if (active) then
      return;
    end

    active = true;

    -- limit number of popup.
    if (#popups > 3) then
      popups[0]:Destroy();
    end

    local defaultSize = UDim2(0, 250, 0, 226);
    local container: Frame = popupParent.Container;
    local position = UDim2(0, container.AbsolutePosition.X + container.AbsoluteSize.X + 20, 0, (container.AbsolutePosition.Y + container.AbsoluteSize.Y) / 2);

    local function createToolbarItem(text: string)
      return CreateInstance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2(0, 62, 1, 0),
      }, {
        CreateInstance("TextLabel", {
          BackgroundTransparency = 1,
          Size = UDim2(0, 25, 1, 0),
          Font = Enum.Font.SourceSansSemibold,
          Text = string.format("%s: ", text),
          TextColor3 = _Color3(255, 255, 255),
          TextSize = 16
        }),
        CreateInstance("TextBox", {
          BackgroundColor3 = _Color3(40, 40, 40),
          BorderSizePixel = 0,
          Position = UDim2(0.4, 0, 0, 0),
          Size = UDim2(0, 40, 1, 0),
          Font = Enum.Font.Arial,
          Text = "",
          TextColor3 = _Color3(255, 255, 255),
          TextSize = 14,
        }, {
          CreateInstance("UICorner", { CornerRadius = UDim(0, 5) }),
        })
      });
    end

    local tb_R = createToolbarItem("R");
    local tb_G = createToolbarItem("G");
    local tb_B = createToolbarItem("B");

    local popup = CreateInstance("Frame", {
      Name = "colorpickerPopup",
      Parent = popupParent,
      AnchorPoint = Vector2(0.5, 0.5),
      BackgroundColor3 = themes.ModuleBackground,
      ClipsDescendants = true,
      Size = UDim2(0, 0, 0, 0),
      Position = position,
      BorderSizePixel = 0
    }, {
      CreateInstance("Frame", {
        BackgroundColor3 = _Color3(20, 20, 20),
        BorderSizePixel = 0,
        Size = UDim2(1, 0, 0, 20),
        Name = "Header",
      }, {
        CreateInstance("TextLabel", {
          BackgroundTransparency = 1,
          Size = UDim2(1, 0, 0, 20),
          Font = Enum.Font.SourceSansSemibold,
          Text = "ColorPicker",
          TextColor3 = _Color3(255, 255, 255),
          TextSize = 14,
          TextXAlignment = Enum.TextXAlignment.Left,
        }),
        CreateInstance("UIPadding", {
          PaddingLeft = UDim(0, 5),
        }),
        CreateInstance("TextButton", {
          BackgroundTransparency = 1,
          BorderSizePixel = 0,
          Position = UDim2(0.9, 0, -0.15, 0),
          Size = UDim2(0, 25, 0, 25),
          Font = Enum.Font.SourceSansBold,
          Text = "X",
          TextColor3 = _Color3(255, 255, 255),
          TextSize = 14,
        }),
      }),
      CreateInstance("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2(0, 0, 0.088, 0),
        Size = UDim2(0, 250, 0, 206),
      }, {
        CreateInstance("TextButton", {
          BackgroundColor3 = _Color3(255, 0, 0),
          BorderSizePixel = 0,
          AnchorPoint = Vector2(0, 0.5),
          Position = UDim2(0, 20, 0.4, 0),
          Size = UDim2(0, 133, 0, 133),
          Name = "SV",
          Text = "",
        }, {
          CreateInstance("Frame", {
            AnchorPoint = Vector2(0.5, 0.5),
            BackgroundColor3 = _Color3(255, 255, 255),
            BorderSizePixel = 0,
            Position = UDim2(0.5, 0, 0.5, 0),
            Size = UDim2(1, 0, 1, 0),
            Name = "White",
          }, {
            CreateInstance("UIGradient", {
              Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
            })
          }),
          CreateInstance("Frame", {
            Name = "Black",
            AnchorPoint = Vector2(0.5, 0.5),
            BackgroundColor3 = _Color3(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2(0.5, 0, 0.5, 0),
            Size = UDim2(1, 0, 1, 0),
          }, {
            CreateInstance("UIGradient", {
              Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)},
              Rotation = -90,
            })
          }),
          CreateInstance("ImageLabel", {
            Name = "Mover",
            BackgroundTransparency = 1,
            Position = UDim2(0.468468457, 0, 0.468468487, 0),
            Size = UDim2(0, 11, 0, 11),
            Image = "rbxassetid://5100115962",
          })
        }),
        CreateInstance("TextButton", {
          Name = "Hue",
          BackgroundColor3 = _Color3(255, 255, 255),
          AnchorPoint = Vector2(0, 0.5),
          Position = UDim2(0.7, 0, 0.4, 0),
          Size = UDim2(0, 16, 0, 133),
          Text = "",
          BorderSizePixel = 0,
        }, {
          CreateInstance("UIGradient", {
            Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, _Color3(255, 0, 0)), ColorSequenceKeypoint.new(0.17, _Color3(255, 255, 0)), ColorSequenceKeypoint.new(0.33, _Color3(0, 255, 0)), ColorSequenceKeypoint.new(0.50, _Color3(0, 255, 255)), ColorSequenceKeypoint.new(0.67, _Color3(0, 0, 255)), ColorSequenceKeypoint.new(0.83, _Color3(255, 0, 255)), ColorSequenceKeypoint.new(1.00, _Color3(255, 0, 0))},
            Rotation = 90,
          }),
          CreateInstance("UICorner", { CornerRadius = UDim(0, 4) }),
          CreateInstance("ImageLabel", {
            Name = "Mover",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2(0.5, 0),
            Size = UDim2(0, 11, 0, 11),
            Image = "rbxassetid://5100115962",
            Position = UDim2(0.5, 0, 0, 0),
          })
        }),
        CreateInstance("Frame", {
          Name = "toolbar",
          BackgroundTransparency = 1,
          AnchorPoint = Vector2(0.5, 0),
          Position = UDim2(0.5, 0, 0.8, 0),
          Size = UDim2(0, 215, 0, 20),
        }, {
          CreateInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal
          }),
          tb_R,
          tb_G,
          tb_B,
        })
      })
    });

    Tween({
      instance = popup,
      info = TweenInfo.new(0.2),
      properties = {
        Size = defaultSize,
      },
    });

    Draggable(popup.Header, popup);

    local exit: TextButton = popup.Header.TextButton;

    table.insert(popups, {
      callback = callback,
      instance = popup,
    })

    exit.MouseButton1Click:Connect(function()
      for i,v in pairs (popups) do
        if (v.callback == callback) then
          table.remove(popups, i);
        end
      end

      Tween({
        instance = popup,
        info = TweenInfo.new(0.2),
        properties = {
          Size = UDim2(0, 0, 0, 0),
        }
      }).Completed:Connect(function()
        popup:Destroy();
        active = false;
      end)
    end)

    local color = {1, 1, 1};

    local SV: TextButton = popup.Frame.SV;
    local Hue: TextButton = popup.Frame.Hue;

    local SVdown = false;
    local HueDown = false;

    DraggingEnded(function()
      HueDown = false;
      SVdown = false;
    end)

    SV.MouseButton1Down:Connect(function()
      SVdown = true;

      while SVdown do
        local X = math.clamp((Mouse.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X,0,1);
        local Y = math.clamp((Mouse.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y,0,1);

        color = {color[1], X, 1 - Y};

        self:updateColorpicker(colorpicker, popup, color);

        local res = HsvToRgb(unpack(color));

        callback(res);

        RunService.RenderStepped:Wait();
      end
    end)

    Hue.MouseButton1Down:Connect(function()
      HueDown = true;

      while HueDown do
        local Y = math.clamp((Mouse.Y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y,0,1);

        self:updateColorpicker(colorpicker, popup, color);

        color = { Y, color[2], color[3] }

        local res = HsvToRgb(unpack(color));

        callback(res);
        RunService.RenderStepped:Wait();
      end
    end)
  end)

end

function page:updateColorpicker(mainInstance, popup, color)
  if (mainInstance and popup) then
    if (color) then
      local Hue: TextButton = popup.Frame.Hue;
      local SV: TextButton = popup.Frame.SV;
      local h,s,v;

      if (typeof(color) == "table") then
        h,s,v = unpack(color);
      else
        h,s,v = Color3.toHSV(color);
      end

      Tween({
        instance = mainInstance.TextButton,
        info = TweenInfo.new(0.2),
        properties = {
          BackgroundColor3 = Color3.fromHSV(h, s, v)
        }
      });
      Tween({
        instance = Hue.Mover,
        info = TweenInfo.new(0.2),
        properties = {
          Position = UDim2(0.5, 0, h, 0)
        }
      });
      Tween({
        instance = SV.Mover,
        info = TweenInfo.new(0.2),
        properties = {
          Position = UDim2(s, 0, math.abs(v - 1), 0)
        }
      });
      Tween({
        instance = SV,
        info = TweenInfo.new(0.2),
        properties = {
          BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        }
      });
    end
  end
end

return library;