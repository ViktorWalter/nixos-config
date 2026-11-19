class Redwood::ThreadViewMode
  def view_browser
    chunk = @chunk_lines[curpos] or return
    view chunk
  end
end
