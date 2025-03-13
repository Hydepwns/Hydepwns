# Image Optimization Guide

This guide explains the image optimization approach used in the Hydepwns project and how to incorporate optimized images in new components.

## Current Implementation

The project already implements a comprehensive image optimization strategy with:

1. **WebP Conversion** - All images are available in both original format (PNG/JPEG) and WebP format
2. **Multiple Resolutions** - Each image is available in multiple sizes (320w, 640w, 960w, 1280w, 1920w)
3. **Quality Levels** - Each WebP image is available in multiple quality levels (low, medium, high)
4. **Responsive Directory Structure** - Organized in `/priv/static/images/responsive/{image_name}/`

## How to Use Optimized Images

### Basic Usage with picture Element

The HTML `<picture>` element allows you to provide multiple sources for an image, letting the browser choose the best one based on screen size, device capabilities, and network conditions:

```html
<picture>
  <!-- WebP versions in different sizes -->
  <source
    type="image/webp"
    srcset="
      /images/responsive/foxheist1/foxheist1-320w-medium.webp 320w,
      /images/responsive/foxheist1/foxheist1-640w-medium.webp 640w,
      /images/responsive/foxheist1/foxheist1-960w-medium.webp 960w,
      /images/responsive/foxheist1/foxheist1-1280w-medium.webp 1280w,
      /images/responsive/foxheist1/foxheist1-1920w-medium.webp 1920w
    "
    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
  />
  
  <!-- Fallback PNG versions for browsers that don't support WebP -->
  <source
    srcset="
      /images/responsive/foxheist1/foxheist1-320w.png 320w,
      /images/responsive/foxheist1/foxheist1-640w.png 640w,
      /images/responsive/foxheist1/foxheist1-960w.png 960w,
      /images/responsive/foxheist1/foxheist1-1280w.png 1280w,
      /images/responsive/foxheist1/foxheist1-1920w.png 1920w
    "
    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
  />
  
  <!-- Final fallback for older browsers -->
  <img 
    src="/images/foxheist1.png"
    alt="Fox Heist Image" 
    loading="lazy"
    width="640"
    height="360"
  />
</picture>
```

### In Elixir/Phoenix Components

Create a reusable component for responsive images:

```elixir
def responsive_image(assigns) do
  ~H"""
  <picture>
    <!-- WebP versions -->
    <source
      type="image/webp"
      srcset={build_srcset(@image_name, @quality || "medium", "webp")}
      sizes={@sizes || "(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"}
    />
    
    <!-- Original format versions -->
    <source
      srcset={build_srcset(@image_name, nil, @original_format || "png")}
      sizes={@sizes || "(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"}
    />
    
    <!-- Fallback -->
    <img 
      src={"/images/#{@image_name}.#{@original_format || "png"}"}
      alt={@alt || @image_name} 
      loading={@loading || "lazy"}
      width={@width}
      height={@height}
      class={@class}
    />
  </picture>
  """
end

# Helper function to build srcset
def build_srcset(image_name, quality, format) do
  widths = [320, 640, 960, 1280, 1920]
  
  srcset = widths
    |> Enum.map(fn width ->
      quality_suffix = if quality, do: "-#{quality}", else: ""
      "/images/responsive/#{image_name}/#{image_name}-#{width}w#{quality_suffix}.#{format} #{width}w"
    end)
    |> Enum.join(", ")
    
  srcset
end
```

### Lazy Loading

All images should use lazy loading unless they are above the fold:

```html
<img src="..." alt="..." loading="lazy" />
```

### Width and Height Attributes

Always specify width and height attributes to reduce layout shift:

```html
<img src="..." alt="..." width="640" height="360" />
```

## Adding New Optimized Images

When adding new images to the project:

1. Place the original high-quality image in `/priv/static/images/`
2. Create a directory for responsive versions: `/priv/static/images/responsive/{image_name}/`
3. Generate responsive versions using the image processing script:

```bash
# Run the image optimization script
mix hydepwns.optimize_images my_new_image.png
```

## Performance Benefits

The implemented image optimization strategy provides:

1. **Faster Load Times** - WebP images are 25-35% smaller than PNG/JPEG
2. **Reduced Bandwidth Usage** - Only the appropriate size image is loaded
3. **Better Mobile Experience** - Mobile devices receive appropriately sized images
4. **Reduced Layout Shift** - Proper width/height attributes prevent layout shift
5. **Progressive Loading** - Low quality images can load first, then higher quality

## Browser Support

- WebP is supported in all modern browsers (Chrome, Firefox, Safari 14+, Edge)
- The `<picture>` element provides automatic fallbacks for older browsers
- Legacy browsers will display the fallback image specified in the `<img>` tag 