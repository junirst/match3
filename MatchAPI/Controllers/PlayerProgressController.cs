using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MatchAPI.Models2;

namespace MatchAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlayerProgressController : ControllerBase
    {
        private readonly DBContextTest2 _context;

        public PlayerProgressController(DBContextTest2 context)
        {
            _context = context;
        }

        // GET: api/PlayerProgress/player/{playerId}
        [HttpGet("player/{playerId}")]
        public async Task<ActionResult<IEnumerable<PlayerProgress>>> GetPlayerProgress(string playerId)
        {
            var progress = await _context.PlayerProgresses
                .Include(pp => pp.Chapter)
                .Where(pp => pp.PlayerId == playerId)
                .OrderBy(pp => pp.Chapter!.ChapterId)
                .ThenBy(pp => pp.LevelNumber)
                .ToListAsync();

            return progress;
        }

        // GET: api/PlayerProgress/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<PlayerProgress>> GetPlayerProgress(int id)
        {
            var playerProgress = await _context.PlayerProgresses
                .Include(pp => pp.Player)
                .Include(pp => pp.Chapter)
                .FirstOrDefaultAsync(pp => pp.ProgressId == id);

            if (playerProgress == null)
            {
                return NotFound();
            }

            return playerProgress;
        }

        // POST: api/PlayerProgress/complete
        [HttpPost("complete")]
        public async Task<ActionResult<PlayerProgress>> CompleteLevel([FromBody] CompleteLevelRequest request)
        {
            // Check if player exists
            var player = await _context.Players.FindAsync(request.PlayerId);
            if (player == null)
            {
                return BadRequest("Player not found");
            }

            // Check if chapter exists
            var chapter = await _context.Chapters.FindAsync(request.ChapterId);
            if (chapter == null)
                return BadRequest("Chapter not found");

            // Check if progress already exists
            var existingProgress = await _context.PlayerProgresses
                .FirstOrDefaultAsync(pp => pp.PlayerId == request.PlayerId && 
                                         pp.ChapterId == request.ChapterId && 
                                         pp.LevelNumber == request.LevelNumber);

            PlayerProgress progress;

            if (existingProgress != null)
            {
                // Update existing progress if new score is better
                if (request.Score > (existingProgress.BestScore ?? 0))
                {
                    existingProgress.BestScore = request.Score;
                    existingProgress.CompletionDate = DateTime.Now;
                }
                
                if (existingProgress.IsCompleted != true)
                {
                    existingProgress.IsCompleted = true;
                    existingProgress.CompletionDate = DateTime.Now;
                }
                
                progress = existingProgress;
            }
            else
            {
                // Create new progress entry
                progress = new PlayerProgress
                {
                    PlayerId = request.PlayerId,
                    ChapterId = request.ChapterId,
                    LevelNumber = request.LevelNumber,
                    IsCompleted = true,
                    BestScore = request.Score,
                    CompletionDate = DateTime.Now
                };

                _context.PlayerProgresses.Add(progress);
            }

            // Award coins to player
            if (request.CoinsEarned > 0)
            {
                player.Coins = (player.Coins ?? 0) + request.CoinsEarned;
            }

            await _context.SaveChangesAsync();

            return Ok(progress);
        }

        // GET: api/PlayerProgress/player/{playerId}/summary
        [HttpGet("player/{playerId}/summary")]
        public async Task<ActionResult<object>> GetPlayerProgressSummary(string playerId)
        {
            var player = await _context.Players.FindAsync(playerId);
            if (player == null)
            {
                return NotFound("Player not found");
            }

            var progress = await _context.PlayerProgresses
                .Include(pp => pp.Chapter)
                .Where(pp => pp.PlayerId == playerId)
                .ToListAsync();

            var summary = new
            {
                PlayerId = playerId,
                PlayerName = player.PlayerName,
                TotalLevelsCompleted = progress.Count(p => p.IsCompleted == true),
                TotalScore = progress.Sum(p => p.BestScore ?? 0),
                ChaptersProgress = progress
                    .GroupBy(p => new { p.ChapterId, p.Chapter!.ChapterName })
                    .Select(g => new
                    {
                        ChapterId = g.Key.ChapterId,
                        ChapterName = g.Key.ChapterName,
                        CompletedLevels = g.Count(p => p.IsCompleted == true),
                        TotalLevels = g.Count(),
                        BestScore = g.Max(p => p.BestScore ?? 0),
                        CompletionPercentage = g.Count() > 0 ? (double)g.Count(p => p.IsCompleted == true) / g.Count() * 100 : 0
                    })
                    .OrderBy(c => c.ChapterId)
                    .ToList(),
                LastCompletedLevel = progress
                    .Where(p => p.IsCompleted == true && p.CompletionDate.HasValue)
                    .OrderByDescending(p => p.CompletionDate)
                    .Select(p => new
                    {
                        p.ChapterId,
                        ChapterName = p.Chapter!.ChapterName,
                        p.LevelNumber,
                        p.BestScore,
                        p.CompletionDate
                    })
                    .FirstOrDefault()
            };

            return summary;
        }

        // PUT: api/PlayerProgress/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> PutPlayerProgress(int id, [FromBody] UpdatePlayerProgressRequest request)
        {
            var playerProgress = await _context.PlayerProgresses.FindAsync(id);
            if (playerProgress == null)
            {
                return NotFound();
            }

            if (request.BestScore.HasValue && request.BestScore > playerProgress.BestScore)
            {
                playerProgress.BestScore = request.BestScore;
            }

            if (request.IsCompleted.HasValue)
            {
                playerProgress.IsCompleted = request.IsCompleted.Value;
                if (request.IsCompleted.Value && !playerProgress.CompletionDate.HasValue)
                {
                    playerProgress.CompletionDate = DateTime.Now;
                }
            }

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!PlayerProgressExists(id))
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

        // DELETE: api/PlayerProgress/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePlayerProgress(int id)
        {
            var playerProgress = await _context.PlayerProgresses.FindAsync(id);
            if (playerProgress == null)
            {
                return NotFound();
            }

            _context.PlayerProgresses.Remove(playerProgress);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool PlayerProgressExists(int id)
        {
            return _context.PlayerProgresses.Any(e => e.ProgressId == id);
        }
    }

    // Request models
    public class CompleteLevelRequest
    {
        public string PlayerId { get; set; } = string.Empty;
        public int ChapterId { get; set; }
        public int LevelNumber { get; set; }
        public int Score { get; set; }
        public int CoinsEarned { get; set; }
    }

    public class UpdatePlayerProgressRequest
    {
        public int? BestScore { get; set; }
        public bool? IsCompleted { get; set; }
    }
}
