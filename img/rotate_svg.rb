def print_rect(x, y, width, height, fill, opacity)
    if opacity == 1
       return "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{width}\" height=\"#{height}\" fill=\"#{fill}\" />\n"
    end
    return "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{width}\" height=\"#{height}\" fill=\"#{fill}\" opacity=\"#{opacity}\" />\n"
end

stdin = ARGV
unless stdin.length == 1 || stdin.length == 2
    raise ArgumentError, "How to run: ruby rotate_svg.rb <input svg file> <output svg file>"
end
input = File.open(stdin[0])
output = File.new(stdin.length == 2 ? stdin[1] : 'out.svg', 'wb:UTF-8')

output.write(input.readline)

svg_items = input.readline.split(/[" =]/).reject { |s| s.empty? }
svg_width = svg_items[svg_items.index("width") + 1].to_i
svg_height = svg_items[svg_items.index("height") + 1].to_i
output.write("<svg version=\"1.1\" width=\"#{svg_height}\" height=\"#{svg_width}\" xmlns=\"http://www.w3.org/2000/svg\" shape-rendering=\"crispEdges\">\n")

canvas = []
while !input.eof?
    input_line = input.readline
    line = input_line.split(/[" =]/).reject { |s| s.empty? }
    unless line.include?("<rect")
        next
    end
    color = line[line.index("fill") + 1]
    opacity = line.include?("opacity") ? line[line.index("opacity") + 1] : 1
    x = line[line.index("x") + 1].to_i
    y = line[line.index("y") + 1].to_i
    width = line[line.index("width") + 1].to_i
    height = line[line.index("height") + 1].to_i
    canvas.append({
        :x => x,
        :y => y,
        :width => width,
        :height => height,
        :color => color,
        :opacity => opacity
    })
end

canvas = canvas.sort { |a, b| [a[:x], a[:y], -a[:width]] <=> [b[:x], b[:y], -b[:width]] }


for step in canvas
    output.write(print_rect(step[:y], step[:x], step[:height], step[:width], step[:color], step[:opacity]))
end

output.write("</svg>")