export const SantaCanvas = {
  mounted() {
    const canvas = this.el
    const ctx = canvas.getContext("2d")

    const render = ({ santa, robo = null, visited }) => {
      ctx.clearRect(0, 0, canvas.width, canvas.height)

      if (visited.length === 0) return

      // Get bounding box
      const xs = visited.map(([pos]) => pos.x)
      const ys = visited.map(([pos]) => pos.y)

      const minX = Math.min(...xs)
      const maxX = Math.max(...xs)
      const minY = Math.min(...ys)
      const maxY = Math.max(...ys)

      const gridWidth = maxX - minX + 1
      const gridHeight = maxY - minY + 1

      const cellSize = Math.min(Math.floor(
        Math.min(canvas.width / gridWidth, canvas.height / gridHeight)
      ), 20)

      const offsetX = Math.floor((canvas.width - gridWidth * cellSize) / 2)
      const offsetY = Math.floor((canvas.height - gridHeight * cellSize) / 2)

      // Draw visited houses
      visited.forEach(([pos]) => {
        const drawX = offsetX + (pos.x - minX) * cellSize
        const drawY = offsetY + (maxY - pos.y) * cellSize
        ctx.fillStyle = "#059669"
        ctx.fillRect(drawX, drawY, cellSize, cellSize)
      })

      // Draw Santa
      const [sx, sy] = santa
      const santaX = offsetX + (sx - minX) * cellSize
      const santaY = offsetY + (maxY - sy) * cellSize
      ctx.font = `${cellSize}px serif`
      ctx.textAlign = "center"
      ctx.textBaseline = "middle"
      ctx.fillText("🎅", santaX + cellSize / 2, santaY + cellSize / 2)

      // If Robo-Santa is present, draw him too
      if (robo) {
        const [rx, ry] = robo
        const roboX = offsetX + (rx - minX) * cellSize
        const roboY = offsetY + (maxY - ry) * cellSize
        ctx.fillText("🤖", roboX + cellSize / 2, roboY + cellSize / 2)
      }
    }

    this.handleEvent("santa:update", render)
    this.handleEvent("santa_robo:update", render)
  }
}
