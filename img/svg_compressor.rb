def print_rect(x, y, width, height, fill, opacity)
    if opacity == 1
       return "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{width}\" height=\"#{height}\" fill=\"#{fill}\" />\n"
    end
    return "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{width}\" height=\"#{height}\" fill=\"#{fill}\" opacity=\"#{opacity}\" />\n"
end

stdin = ARGV
unless stdin.length == 1 || stdin.length == 2
    raise ArgumentError, "How to run: ruby svg_compressor.rb <input svg file> <output svg file>"
end
input = File.open(stdin[0])
output = File.new(stdin.length == 2 ? stdin[1] : 'out.svg', 'wb:UTF-8')

# Waste a line
output.write(input.readline)

svg_line = input.readline
output.write(svg_line)
svg_items = svg_line.split(/[" =]/).reject { |s| s.empty? }
width = svg_items[svg_items.index("width") + 1].to_i
height = svg_items[svg_items.index("height") + 1].to_i

canvas = []
color_freq = {}

curr_color = nil
curr_opacity = -1
curr_width = -1
curr_x = -1
curr_y = -1

while !input.eof?
    line = input.readline.split(/[" =]/).reject { |s| s.empty? }
    unless line.include?("<rect")
        next
    end
    color = line[line.index("fill") + 1]
    opacity = line.include?("opacity") ? line[line.index("opacity") + 1] : 1
    x = line[line.index("x") + 1].to_i
    y = line[line.index("y") + 1].to_i
    if color_freq.include?([color, opacity])
        color_freq[[color, opacity]] += 1
    else
        color_freq[[color, opacity]] = 1
    end
    if curr_color.nil?
        curr_color = color
        curr_opacity = opacity
        curr_width = 1
        curr_x = x
        curr_y = y
        next
    end
    if curr_color != color || curr_y != y
        canvas.append({
            :x => curr_x,
            :y => curr_y,
            :width => curr_width,
            :height => 1,
            :color => curr_color,
            :opacity => curr_opacity
        })
        curr_color = color
        curr_opacity = opacity
        curr_width = 0
        curr_x = x
        curr_y = y
    end
    curr_width += 1
end

# Write the max
p color_freq
frequent_color = color_freq.max_by { |k, v| v } [0]
output.write(print_rect(0, 0, width, height, frequent_color[0], frequent_color[1]))

for step in canvas
    if step[:color] == frequent_color[0] && step[:opacity] == frequent_color[1]
        next
    end
    output.write(print_rect(step[:x], step[:y], step[:width], 1, step[:color], step[:opacity]))
end

output.write("</svg>")