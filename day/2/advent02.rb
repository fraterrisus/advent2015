total_paper_area_required = 0
total_ribbon_length_required = 0

File.readlines('input.txt').map { |d| d.chomp.split('x').map(&:to_i) }.each do |dims|
  this_present_volume =
    dims[0] * dims[1] * dims[2]
  face_surface_areas = 
    [ dims[0] * dims[1], dims[1] * dims[2], dims[0] * dims[2] ]
  this_present_surface_area = 
    2*face_surface_areas[0] + 2*face_surface_areas[1] + 2*face_surface_areas[2]
  this_present_circumferences =
    [ 2*(dims[0] + dims[1]), 2*(dims[1] + dims[2]), 2*(dims[0] + dims[2]) ]
  paper_area_required = 
    this_present_surface_area + face_surface_area.min
  total_paper_area_required += paper_area_required
  ribbon_length_required =
    this_present_circumferences.min + this_present_volume
  total_ribbon_length_required += ribbon_length_required
end

puts "Total paper area needed: #{total_paper_area_required}"
puts "Total ribbon length needed: #{total_ribbon_length_required}"
