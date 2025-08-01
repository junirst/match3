using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MatchAPI.Models2;

namespace MatchAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LeaderboardController : ControllerBase
    {
        private readonly DBContextTest2 _context;

        public LeaderboardController(DBContextTest2 context)
        {
            _context = context;
        }

        // GET: api/Leaderboard
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetLeaderboard([FromQuery] int limit = 50)
        {
            var leaderboard = await _context.Leaderboards
                .Include(l => l.Player)
                .Include(l => l.Season)
                .OrderByDescending(l => l.Score)
                .Take(limit)
                .Select(l => new
                {
                    l.LeaderboardId,
                    l.PlayerId,
                    PlayerName = l.Player.PlayerName,
                    l.Score,
                    l.Rank,
                    l.SeasonId,
                    l.CreatedDate
                })
                .ToListAsync();

            return Ok(leaderboard);
        }

        // GET: api/Leaderboard/season/{seasonId}
        [HttpGet("season/{seasonId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetSeasonLeaderboard(int seasonId, [FromQuery] int limit = 50)
        {
            var leaderboard = await _context.Leaderboards
                .Include(l => l.Player)
                .Where(l => l.SeasonId == seasonId)
                .OrderByDescending(l => l.Score)
                .Take(limit)
                .Select(l => new
                {
                    l.LeaderboardId,
                    l.PlayerId,
                    PlayerName = l.Player.PlayerName,
                    l.Score,
                    l.Rank,
                    l.CreatedDate
                })
                .ToListAsync();

            return Ok(leaderboard);
        }

        // GET: api/Leaderboard/player/{playerId}
        [HttpGet("player/{playerId}")]
        public async Task<ActionResult<object>> GetPlayerRanking(string playerId)
        {
            var playerRanking = await _context.Leaderboards
                .Include(l => l.Player)
                .Include(l => l.Season)
                .Where(l => l.PlayerId == playerId)
                .OrderByDescending(l => l.CreatedDate)
                .Select(l => new
                {
                    l.LeaderboardId,
                    l.PlayerId,
                    PlayerName = l.Player.PlayerName,
                    l.Score,
                    l.Rank,
                    l.SeasonId,
                    l.CreatedDate
                })
                .ToListAsync();

            if (!playerRanking.Any())
            {
                return NotFound("Player not found in leaderboard");
            }

            return Ok(playerRanking);
        }

        // GET: api/Leaderboard/tower
        [HttpGet("tower")]
        public async Task<ActionResult<IEnumerable<object>>> GetTowerLeaderboard([FromQuery] int limit = 50)
        {
            var towerLeaderboard = await _context.Players
                .Where(p => p.TowerRecord > 0)
                .OrderByDescending(p => p.TowerRecord)
                .Take(limit)
                .Select((p, index) => new
                {
                    Rank = index + 1,
                    p.PlayerId,
                    p.PlayerName,
                    TowerRecord = p.TowerRecord ?? 0,
                    p.LastLoginDate
                })
                .ToListAsync();

            return Ok(towerLeaderboard);
        }

        // POST: api/Leaderboard
        [HttpPost]
        public async Task<ActionResult<Leaderboard>> PostLeaderboard([FromBody] CreateLeaderboardRequest request)
        {
            // Check if player exists
            var player = await _context.Players.FindAsync(request.PlayerId);
            if (player == null)
            {
                return BadRequest("Player not found");
            }

            // Check if season exists (if provided)
            if (request.SeasonId.HasValue)
            {
                var season = await _context.Seasons.FindAsync(request.SeasonId.Value);
                if (season == null)
                {
                    return BadRequest("Season not found");
                }
            }

            var leaderboardEntry = new Leaderboard
            {
                PlayerId = request.PlayerId,
                Score = request.Score,
                SeasonId = request.SeasonId ?? 1, // Default to season 1 if not provided
                CreatedDate = DateTime.Now
            };

            _context.Leaderboards.Add(leaderboardEntry);
            await _context.SaveChangesAsync();

            // Update ranks for the season or overall
            await UpdateRanks(request.SeasonId);

            return CreatedAtAction("GetLeaderboard", new { id = leaderboardEntry.LeaderboardId }, leaderboardEntry);
        }

        // PUT: api/Leaderboard/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> PutLeaderboard(int id, [FromBody] UpdateLeaderboardRequest request)
        {
            var leaderboardEntry = await _context.Leaderboards.FindAsync(id);
            if (leaderboardEntry == null)
            {
                return NotFound();
            }

            leaderboardEntry.Score = request.Score;

            try
            {
                await _context.SaveChangesAsync();
                
                // Update ranks for the season or overall
                await UpdateRanks(leaderboardEntry.SeasonId);
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!LeaderboardExists(id))
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

        // DELETE: api/Leaderboard/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteLeaderboard(int id)
        {
            var leaderboardEntry = await _context.Leaderboards.FindAsync(id);
            if (leaderboardEntry == null)
            {
                return NotFound();
            }

            var seasonId = leaderboardEntry.SeasonId;
            _context.Leaderboards.Remove(leaderboardEntry);
            await _context.SaveChangesAsync();

            // Update ranks after deletion
            await UpdateRanks(seasonId);

            return NoContent();
        }

        private async Task UpdateRanks(int? seasonId)
        {
            List<Leaderboard> entries;
            
            if (seasonId.HasValue)
            {
                entries = await _context.Leaderboards
                    .Where(l => l.SeasonId == seasonId.Value)
                    .OrderByDescending(l => l.Score)
                    .ToListAsync();
            }
            else
            {
                // Get all entries for default season (1)
                entries = await _context.Leaderboards
                    .Where(l => l.SeasonId == 1)
                    .OrderByDescending(l => l.Score)
                    .ToListAsync();
            }

            for (int i = 0; i < entries.Count; i++)
            {
                entries[i].Rank = i + 1;
            }

            await _context.SaveChangesAsync();
        }

        private bool LeaderboardExists(int id)
        {
            return _context.Leaderboards.Any(e => e.LeaderboardId == id);
        }
    }

    // Request models
    public class CreateLeaderboardRequest
    {
        public string PlayerId { get; set; } = string.Empty;
        public int Score { get; set; }
        public int? SeasonId { get; set; }
    }

    public class UpdateLeaderboardRequest
    {
        public int Score { get; set; }
    }
}
