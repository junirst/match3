using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MatchAPI.Models2;

namespace MatchAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChapterController : ControllerBase
    {
        private readonly DBContextTest2 _context;

        public ChapterController(DBContextTest2 context)
        {
            _context = context;
        }

        // GET: api/Chapter
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Chapter>>> GetChapters()
        {
            return await _context.Chapters
                .Include(c => c.Levels)
                .OrderBy(c => c.ChapterId)
                .ToListAsync();
        }

        // GET: api/Chapter/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Chapter>> GetChapter(int id)
        {
            var chapter = await _context.Chapters
                .Include(c => c.Levels.OrderBy(l => l.LevelNumber))
                .FirstOrDefaultAsync(c => c.ChapterId == id);

            if (chapter == null)
            {
                return NotFound();
            }

            return chapter;
        }

        // GET: api/Chapter/{id}/levels
        [HttpGet("{id}/levels")]
        public async Task<ActionResult<IEnumerable<Level>>> GetChapterLevels(int id)
        {
            var chapter = await _context.Chapters.FindAsync(id);
            if (chapter == null)
            {
                return NotFound("Chapter not found");
            }

            var levels = await _context.Levels
                .Where(l => l.ChapterId == id)
                .OrderBy(l => l.LevelNumber)
                .ToListAsync();

            return levels;
        }

        // GET: api/Chapter/player/{playerId}/progress
        [HttpGet("player/{playerId}/progress")]
        public async Task<ActionResult<IEnumerable<object>>> GetPlayerChapterProgress(string playerId)
        {
            var player = await _context.Players.FindAsync(playerId);
            if (player == null)
            {
                return NotFound("Player not found");
            }

            var progress = await _context.PlayerProgresses
                .Include(pp => pp.Chapter)
                .Where(pp => pp.PlayerId == playerId)
                .OrderBy(pp => pp.Chapter!.ChapterId)
                .ThenBy(pp => pp.LevelNumber)
                .Select(pp => new
                {
                    pp.ProgressId,
                    pp.ChapterId,
                    ChapterName = pp.Chapter!.ChapterName,
                    pp.LevelNumber,
                    pp.IsCompleted,
                    pp.BestScore,
                    pp.CompletionDate
                })
                .ToListAsync();

            return Ok(progress);
        }

        // POST: api/Chapter
        [HttpPost]
        public async Task<ActionResult<Chapter>> PostChapter([FromBody] CreateChapterRequest request)
        {
            var chapter = new Chapter
            {
                ChapterName = request.ChapterName,
                Description = request.Description,
                IsUnlocked = request.IsUnlocked ?? false,
                CreatedDate = DateTime.Now
            };

            _context.Chapters.Add(chapter);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetChapter", new { id = chapter.ChapterId }, chapter);
        }

        // PUT: api/Chapter/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> PutChapter(int id, [FromBody] UpdateChapterRequest request)
        {
            var chapter = await _context.Chapters.FindAsync(id);
            if (chapter == null)
            {
                return NotFound();
            }

            if (!string.IsNullOrEmpty(request.ChapterName))
                chapter.ChapterName = request.ChapterName;
            
            if (!string.IsNullOrEmpty(request.Description))
                chapter.Description = request.Description;
            
            if (request.IsUnlocked.HasValue)
                chapter.IsUnlocked = request.IsUnlocked.Value;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ChapterExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/Chapter/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteChapter(int id)
        {
            var chapter = await _context.Chapters.FindAsync(id);
            if (chapter == null)
            {
                return NotFound();
            }

            _context.Chapters.Remove(chapter);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool ChapterExists(int id)
        {
            return _context.Chapters.Any(e => e.ChapterId == id);
        }
    }

    // Request models
    public class CreateChapterRequest
    {
        public string ChapterName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool? IsUnlocked { get; set; }
    }

    public class UpdateChapterRequest
    {
        public string? ChapterName { get; set; }
        public string? Description { get; set; }
        public bool? IsUnlocked { get; set; }
    }
}
