--!strict

type TweenProps = {
  instance: Instance,
  info: TweenInfo,
  properties: Dictionary<any>,
};

type LibraryProps = {
  title: string,
}

type PageProps = {
  library: table?,
  title: string
}

local library = {};
local page = {};
local DraggingEnd = {};
local Debug = {
  log = {}
}

function Debug:addLog(msg: string)
  -- table.insert(Debug.log, string.format("DEBUG: %s", msg));
end

library.__index = library;
page.__index = page;

local TweenService = game:GetService("TweenService");
local RunService = game:GetService("RunService");
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService");

local Color3 = Color3.fromRGB;
local UDim2 = UDim2.new;
local UDim = UDim.new;
local Vector2 = Vector2.new;

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
  table.insert(DraggingEnd, callback);
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

function library.new(data: LibraryProps)
  local ScreenGui = CreateInstance("ScreenGui", {
    Name = ".",
    Parent = game:GetService("CoreGui")
  }, {
    CreateInstance("Frame", {
      Name = "Container",
      AnchorPoint = Vector2(0.5, 0.5),
      BackgroundColor3 = Color3(30, 30, 30),
      BorderSizePixel = 0,
      Position = UDim2(0.5, 0, 0.5, 0),
      Size = UDim2(0, 700, 0, 500),
    }, {
     CreateInstance("UICorner"),
     CreateInstance("ScrollingFrame", {
       Name = "Navigation",
       BackgroundColor3 = Color3(35, 35, 35),
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
       BackgroundColor3 = Color3(40, 40, 40),
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
         TextColor3 = Color3(255, 255, 255),
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
  Draggable(Header, Container);

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
    BackgroundColor3 = Color3(25, 25, 25),
    Size = UDim2(1, -20, 0, 30),
    Font = Enum.Font.SourceSansBold,
    Text = data.title or "Unknown",
    TextColor3 = Color3(255, 255, 255),
    TextSize = 14,
    Parent = data.library.Navigation,
  }, {
    CreateInstance("UICorner", { CornerRadius = UDim(0, 5) })
  })

  local body = CreateInstance("ScrollingFrame", {
    Name = "Body",
    BackgroundColor3 = Color3(35, 35, 35),
    BorderColor3 = Color3(30, 30, 30),
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
    CreateInstance("UIPadding", { PaddingTop = UDim(0, 10) })
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
        BackgroundColor3 = Color3(220, 220, 220),
        TextColor3 = Color3(10, 10, 10),
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
        BackgroundColor3 = Color3(25, 25, 25),
        TextColor3 = Color3(255, 255, 255),
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
      Text = data.title or "",
      TextColor3 = Color3(255, 255, 255),
      TextSize = 17.000,
      TextXAlignment = Enum.TextXAlignment.Left,
    }),
    CreateInstance("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2(1, 0, 0, 30),
      Font = Enum.Font.SourceSans,
      Text = data.description or "",
      TextColor3 = Color3(140, 140, 140),
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
    BackgroundColor3 = Color3(30, 30, 30),
    BorderSizePixel = 0,
    Size = UDim2(1, -60, 0, 90),
    SizeConstraint = Enum.SizeConstraint.RelativeXX,
  }, {
    CreateInstance("TextButton", {
      AnchorPoint = Vector2(0.5, 0.5),
      BackgroundColor3 = Color3(45, 45, 45),
      BorderSizePixel = 0,
      Position = UDim2(0.5, 0, 0.75, 0),
      Size = UDim2(0.9, 0, 0, 30),
      Font = Enum.Font.SourceSansBold,
      Text = data.buttonText or "Execute",
      TextColor3 = Color3(255, 255, 255),
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
    textbutton.BackgroundColor3 = Color3(55, 55, 55);
  end)

  textbutton.MouseButton1Up:Connect(function()
    textbutton.BackgroundColor3 = Color3(45, 45, 45);
    callback();
  end)
end

function page:addToggle(data: ToggleType)
  local callback = typeof(data.callback) == "function" and data.callback or function(value) end;
  local state = data.default or false;

  local toggle = CreateInstance("Frame", {
    Parent = self.page,
    BackgroundColor3 = Color3(30, 30, 30),
    BorderSizePixel = 0,
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
      BackgroundColor3 = Color3(80, 80, 80),
      BorderSizePixel = 0,
      Position = UDim2(0.9, 0, 0.5, 0),
      Size = UDim2(0, 50, 0, 20),
      Text = "",
    }, {
      CreateInstance("UICorner", { CornerRadius = UDim(1, 0) }),
      CreateInstance("UIPadding", { PaddingBottom = UDim(0, 3), PaddingTop = UDim(0, 3), PaddingLeft = UDim(0, 2), PaddingRight = UDim(0, 2) }),
      CreateInstance("Frame", {
        AnchorPoint = Vector2(0, 0.5),
        BackgroundColor3 = Color3(255, 255, 255),
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
    BackgroundColor3 = Color3(30, 30, 30),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Size = UDim2(1, -60, 0, 90),
  }, {
    self:createModuleHeader({title = data.title, description = data.desc}),
    CreateInstance("Frame", {
      AnchorPoint = Vector2(0.5, 0),
      BorderSizePixel = 0,
      Size = UDim2(0.9, 0, 0, 30),
      Position = UDim2(0.5, 0, 0.5, 0),
      Name = "f",
      BackgroundColor3 = Color3(45, 45, 45),
    }, {
      CreateInstance("TextBox", {
        BackgroundColor3 = Color3(45, 45, 45),
        BorderSizePixel = 0,
        Size = UDim2(0.9, 0, 1, 0),
        Font = Enum.Font.Arial,
        Text = "",
        TextColor3 = Color3(255, 255, 255),
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
        BackgroundColor3 = Color3(35, 35, 35),
        BorderSizePixel = 0,
        Position = UDim2(0.9, 0, 0, 0),
        Size = UDim2(0, 1, 1, 0)
      }),
      CreateInstance("UICorner", { CornerRadius = UDim(0, 5) })
    }),
    CreateInstance("ScrollingFrame", {
      BackgroundColor3 = Color3(45, 45, 45),
      BorderSizePixel = 0,
      Position = UDim2(0, 0, 1, 0),
      Size = UDim2(1, 0, 0, 0),
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

  local openButton: ImageButton = dropdown.f.ImageButton;

  openButton.MouseButton1Click:Connect(function()
    if (openButton.Rotation == 180) then
      self:updateDropdown(dropdown, nil, callback);
    else
      self:updateDropdown(dropdown, list, callback);
    end
  end)

  dropdown.ScrollingFrame:GetPropertyChangedSignal("Size"):Connect(function()
    self:Resize(false, dropdown.ScrollingFrame.Size.Y.Offset);
  end)
end

function page:updateDropdown(dropdownInstance: Frame, list, callback)
  if (dropdownInstance) then
    local itemList: ScrollingFrame = dropdownInstance.ScrollingFrame;
    local openButton: ImageButton = dropdownInstance.f.ImageButton;

    for _, Value in pairs (itemList:GetChildren()) do
      if (Value:IsA('TextButton')) then
        Value:Destroy();
      end
    end

    for _, Value in pairs (list or {}) do
      local button: TextButton = CreateInstance("TextButton", {
        BackgroundColor3 = Color3(35, 35, 35),
        Size = UDim2(0.9, 0, 0, 30),
        Font = Enum.Font.SourceSansSemibold,
        Text = Value or "Dropdown Item",
        TextColor3 = Color3(255, 255, 255),
        TextSize = 16,
        Parent = itemList,
        BorderSizePixel = 0,
      });

      button.MouseButton1Up:Connect(function()
        callback(Value);
        self:updateDropdown(dropdownInstance, nil, callback);
      end)
    end

    itemList.CanvasSize = UDim2(0, 0, 0, itemList.UIListLayout.AbsoluteContentSize.Y);
    dropdownInstance.ClipsDescendants = list == nil and true or false;

    Tween({
      instance = itemList,
      info = TweenInfo.new(0.2),
      properties = {
        Size = UDim2(1, 0, 0, list and 250 or 0),
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
