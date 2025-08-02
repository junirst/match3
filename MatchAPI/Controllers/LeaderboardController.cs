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
                    l.TowerLevel,
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
                    l.TowerLevel,
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
                    l.TowerLevel,
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

        // POST: api/Leaderboard/UpdateProgress
        [HttpPost("UpdateProgress")]
        public async Task<ActionResult> UpdatePlayerProgress([FromBody] UpdateProgressRequest request)
        {
            try
            {
                // Validate input
                if (string.IsNullOrEmpty(request.PlayerId))
                {
                    return BadRequest("Player ID is required");
                }

                // Get current season
                var currentSeason = await _context.Seasons
                    .OrderByDescending(s => s.SeasonId)
                    .FirstOrDefaultAsync();

                if (currentSeason == null)
                {
                    return BadRequest("No active season found");
                }

                // Find existing leaderboard entry for this player and season
                var existingEntry = await _context.Leaderboards
                    .FirstOrDefaultAsync(l => l.PlayerId == request.PlayerId && l.SeasonId == currentSeason.SeasonId);

                if (existingEntry == null)
                {
                    // Create new leaderboard entry for first-time player
                    existingEntry = new Leaderboard
                    {
                        PlayerId = request.PlayerId,
                        SeasonId = currentSeason.SeasonId,
                        Score = request.Score ?? 0,
                        TowerLevel = request.TowerLevel ?? 1,
                        CreatedDate = DateTime.UtcNow,
                        UpdatedDate = DateTime.UtcNow
                    };
                    _context.Leaderboards.Add(existingEntry);
                }
                else
                {
                    // Update existing entry only if new values are higher
                    bool updated = false;
                    
                    if (request.Score.HasValue && request.Score.Value > (existingEntry.Score ?? 0))
                    {
                        existingEntry.Score = request.Score.Value;
                        updated = true;
                    }
                    
                    if (request.TowerLevel.HasValue && request.TowerLevel.Value > existingEntry.TowerLevel)
                    {
                        existingEntry.TowerLevel = request.TowerLevel.Value;
                        updated = true;
                    }
                    
                    if (updated)
                    {
                        existingEntry.UpdatedDate = DateTime.UtcNow;
                    }
                }

                await _context.SaveChangesAsync();

                // Recalculate ranks for the season
                await UpdateRanks(currentSeason.SeasonId);

                return Ok(new { message = "Player progress updated successfully", leaderboardId = existingEntry.LeaderboardId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // POST: api/Leaderboard/InitializePlayer
        [HttpPost("InitializePlayer")]
        public async Task<ActionResult> InitializeNewPlayer([FromBody] InitializePlayerRequest request)
        {
            try
            {
                // Validate input
                if (string.IsNullOrEmpty(request.PlayerId))
                {
                    return BadRequest("Player ID is required");
                }

                // Check if player exists
                var player = await _context.Players.FindAsync(request.PlayerId);
                if (player == null)
                {
                    return BadRequest("Player not found");
                }

                // Get current season
                var currentSeason = await _context.Seasons
                    .OrderByDescending(s => s.SeasonId)
                    .FirstOrDefaultAsync();

                if (currentSeason == null)
                {
                    return BadRequest("No active season found");
                }

                // Check if leaderboard entry already exists
                var existingEntry = await _context.Leaderboards
                    .FirstOrDefaultAsync(l => l.PlayerId == request.PlayerId && l.SeasonId == currentSeason.SeasonId);

                if (existingEntry != null)
                {
                    return Ok(new { message = "Player already initialized in leaderboard", leaderboardId = existingEntry.LeaderboardId });
                }

                // Create initial leaderboard entry
                var newEntry = new Leaderboard
                {
                    PlayerId = request.PlayerId,
                    SeasonId = currentSeason.SeasonId,
                    Score = 0,
                    TowerLevel = 1,
                    CreatedDate = DateTime.UtcNow,
                    UpdatedDate = DateTime.UtcNow
                };

                _context.Leaderboards.Add(newEntry);
                await _context.SaveChangesAsync();

                // Recalculate ranks
                await UpdateRanks(currentSeason.SeasonId);

                return Ok(new { message = "Player initialized in leaderboard successfully", leaderboardId = newEntry.LeaderboardId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
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

    public class UpdateProgressRequest
    {
        public string PlayerId { get; set; } = string.Empty;
        public int? Score { get; set; }
        public int? TowerLevel { get; set; }
    }

    public class InitializePlayerRequest
    {
        public string PlayerId { get; set; } = string.Empty;
    }
}
