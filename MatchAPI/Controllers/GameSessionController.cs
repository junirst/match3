using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MatchAPI.Models2;

namespace MatchAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class GameSessionController : ControllerBase
    {
        private readonly DBContextTest2 _context;

        public GameSessionController(DBContextTest2 context)
        {
            _context = context;
        }

        // GET: api/GameSession
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GameSession>>> GetGameSessions()
        {
            return await _context.GameSessions.Include(g => g.Player).ToListAsync();
        }

        // GET: api/GameSession/player/{playerId}
        [HttpGet("player/{playerId}")]
        public async Task<ActionResult<IEnumerable<GameSession>>> GetPlayerGameSessions(string playerId)
        {
            var sessions = await _context.GameSessions
                .Where(g => g.PlayerId == playerId)
                .OrderByDescending(g => g.StartTime)
                .ToListAsync();

            return sessions;
        }

        // GET: api/GameSession/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<GameSession>> GetGameSession(int id)
        {
            var gameSession = await _context.GameSessions
                .Include(g => g.Player)
                .FirstOrDefaultAsync(g => g.SessionId == id);

            if (gameSession == null)
            {
                return NotFound();
            }

            return gameSession;
        }

        // POST: api/GameSession/start
        [HttpPost("start")]
        public async Task<ActionResult<GameSession>> StartGameSession([FromBody] StartGameSessionRequest request)
        {
            var player = await _context.Players.FindAsync(request.PlayerId);
            if (player == null)
            {
                return BadRequest("Player not found");
            }

            var gameSession = new GameSession
            {
                PlayerId = request.PlayerId,
                GameMode = request.GameMode ?? "Chapter",
                ChapterId = request.ChapterId,
                LevelNumber = request.LevelNumber,
                TowerFloor = request.TowerFloor,
                StartTime = DateTime.Now,
                IsCompleted = false
            };

            _context.GameSessions.Add(gameSession);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetGameSession", new { id = gameSession.SessionId }, gameSession);
        }

        // PUT: api/GameSession/{id}/complete
        [HttpPut("{id}/complete")]
        public async Task<ActionResult> CompleteGameSession(int id, [FromBody] CompleteGameSessionRequest request)
        {
            var gameSession = await _context.GameSessions.FindAsync(id);
            if (gameSession == null)
            {
                return NotFound();
            }

            gameSession.EndTime = DateTime.Now;
            gameSession.FinalScore = request.FinalScore;
            gameSession.IsCompleted = true;
            gameSession.EnemyDefeated = request.EnemyDefeated;

            // Update player coins if won and enemy defeated
            if (request.EnemyDefeated == true && request.CoinsEarned > 0)
            {
                var player = await _context.Players.FindAsync(gameSession.PlayerId);
                if (player != null)
                {
                    player.Coins = (player.Coins ?? 0) + request.CoinsEarned;
                }
            }

            // Update tower record if this is a tower game
            if (gameSession.GameMode == "Tower" && request.EnemyDefeated == true)
            {
                var player = await _context.Players.FindAsync(gameSession.PlayerId);
                if (player != null && gameSession.TowerFloor > player.TowerRecord)
                {
                    player.TowerRecord = gameSession.TowerFloor;
                }
            }

            await _context.SaveChangesAsync();

            return Ok(gameSession);
        }

        // GET: api/GameSession/player/{playerId}/stats
        [HttpGet("player/{playerId}/stats")]
        public async Task<ActionResult<object>> GetPlayerStats(string playerId)
        {
            var sessions = await _context.GameSessions
                .Where(g => g.PlayerId == playerId && g.IsCompleted == true)
                .ToListAsync();

            var stats = new
            {
                TotalGamesPlayed = sessions.Count,
                TotalGamesWon = sessions.Count(s => s.EnemyDefeated == true),
                TotalScore = sessions.Sum(s => s.FinalScore ?? 0),
                AverageScore = sessions.Any() ? sessions.Average(s => s.FinalScore ?? 0) : 0,
                WinRate = sessions.Any() ? (double)sessions.Count(s => s.EnemyDefeated == true) / sessions.Count * 100 : 0,
                ChapterGames = sessions.Count(s => s.GameMode == "Chapter"),
                TowerGames = sessions.Count(s => s.GameMode == "Tower"),
                HighestTowerFloor = sessions.Where(s => s.GameMode == "Tower").Max(s => s.TowerFloor) ?? 0
            };

            return stats;
        }

        // DELETE: api/GameSession/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGameSession(int id)
        {
            var gameSession = await _context.GameSessions.FindAsync(id);
            if (gameSession == null)
            {
                return NotFound();
            }

            _context.GameSessions.Remove(gameSession);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }

    // Request models
    public class StartGameSessionRequest
    {
        public string PlayerId { get; set; } = string.Empty;
        public string GameMode { get; set; } = "Chapter";
        public int? ChapterId { get; set; }
        public int? LevelNumber { get; set; }
        public int? TowerFloor { get; set; }
    }

    public class CompleteGameSessionRequest
    {
        public int? FinalScore { get; set; }
        public bool EnemyDefeated { get; set; }
        public int CoinsEarned { get; set; }
    }
}
