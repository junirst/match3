using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MatchAPI.Models2;

namespace MatchAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlayerController : ControllerBase
    {
        private readonly DBContextTest2 _context;

        public PlayerController(DBContextTest2 context)
        {
            _context = context;
        }

        // GET: api/Player
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Player>>> GetPlayers()
        {
            return await _context.Players.ToListAsync();
        }

        // GET: api/Player/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Player>> GetPlayer(string id)
        {
            var player = await _context.Players.FindAsync(id);

            if (player == null)
            {
                return NotFound();
            }

            return player;
        }

        // GET: api/Player/{id}/profile
        [HttpGet("{id}/profile")]
        public async Task<ActionResult<object>> GetPlayerProfile(string id)
        {
            var player = await _context.Players
                .Include(p => p.PlayerProgresses)
                .Include(p => p.PlayerSettings)
                .Include(p => p.PlayerStats)
                .Include(p => p.PlayerWeapons)
                .FirstOrDefaultAsync(p => p.PlayerId == id);

            if (player == null)
            {
                return NotFound();
            }

            var profile = new
            {
                PlayerId = player.PlayerId,
                PlayerName = player.PlayerName,
                Gender = player.Gender,
                LanguagePreference = player.LanguagePreference,
                TowerRecord = player.TowerRecord,
                Coins = player.Coins,
                EquippedWeapon = player.EquippedWeapon,
                CreatedDate = player.CreatedDate,
                LastLoginDate = player.LastLoginDate,
                IsActive = player.IsActive,
                Progress = player.PlayerProgresses,
                Settings = player.PlayerSettings,
                Stats = player.PlayerStats,
                Weapons = player.PlayerWeapons
            };

            return profile;
        }

        // PUT: api/Player/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutPlayer(string id, Player player)
        {
            if (id != player.PlayerId)
            {
                return BadRequest();
            }

            _context.Entry(player).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!PlayerExists(id))
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

        // PUT: api/Player/{id}/updateProfile
        [HttpPut("{id}/updateProfile")]
        public async Task<IActionResult> UpdatePlayerProfile(string id, [FromBody] UpdatePlayerProfileRequest request)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
            {
                return NotFound();
            }

            if (!string.IsNullOrEmpty(request.PlayerName))
                player.PlayerName = request.PlayerName;
            
            if (!string.IsNullOrEmpty(request.Gender))
                player.Gender = request.Gender;
            
            if (!string.IsNullOrEmpty(request.LanguagePreference))
                player.LanguagePreference = request.LanguagePreference;

            player.LastLoginDate = DateTime.Now;

            try
            {
                await _context.SaveChangesAsync();
                return Ok(player);
            }
            catch (DbUpdateException)
            {
                return StatusCode(500, "Error updating player profile");
            }
        }

        // POST: api/Player
        [HttpPost]
        public async Task<ActionResult<Player>> PostPlayer(Player player)
        {
            // Set default values
            player.CreatedDate = DateTime.Now;
            player.LastLoginDate = DateTime.Now;
            player.IsActive = true;
            player.Coins = 0;
            player.TowerRecord = 0;

            _context.Players.Add(player);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (PlayerExists(player.PlayerId))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction("GetPlayer", new { id = player.PlayerId }, player);
        }

        // POST: api/Player/login
        [HttpPost("login")]
        public async Task<ActionResult<object>> LoginPlayer([FromBody] LoginRequest request)
        {
            var player = await _context.Players
                .FirstOrDefaultAsync(p => p.Email == request.Email && p.Password == request.Password);
            
            if (player == null)
            {
                return Unauthorized("Invalid Email or Password");
            }

            // Update last login date
            player.LastLoginDate = DateTime.Now;
            player.IsActive = true;
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Login successful", Player = player });
        }

        // POST: api/Player/register
        [HttpPost("register")]
        public async Task<ActionResult<object>> RegisterPlayer([FromBody] RegisterRequest request)
        {
            // Generate unique Player ID
            string playerId = GenerateUniquePlayerId();

            // Check if email already exists
            if (!string.IsNullOrEmpty(request.Email))
            {
                var existingEmail = await _context.Players
                    .FirstOrDefaultAsync(p => p.Email == request.Email);
                if (existingEmail != null)
                {
                    return Conflict("Email already exists");
                }
            }

            var player = new Player
            {
                PlayerId = playerId,
                PlayerName = request.PlayerName,
                Password = request.Password,
                Email = request.Email,
                Gender = request.Gender,
                LanguagePreference = request.LanguagePreference,
                CreatedDate = DateTime.Now,
                LastLoginDate = DateTime.Now,
                IsActive = true,
                Coins = 100, // Starting coins
                TowerRecord = 0
            };

            _context.Players.Add(player);
            
            try
            {
                await _context.SaveChangesAsync();
                return Created($"api/Player/{player.PlayerId}", new { 
                    Message = "Registration successful", 
                    Player = player 
                });
            }
            catch (DbUpdateException)
            {
                return StatusCode(500, "Error creating player");
            }
        }

        private string GenerateUniquePlayerId()
        {
            string playerId;
            do
            {
                // Generate a random Player ID with prefix "PLR" and 8 digits
                playerId = "PLR" + Random.Shared.Next(10000000, 99999999).ToString();
            }
            while (PlayerExists(playerId)); // Keep generating until we find a unique one
            
            return playerId;
        }

        // POST: api/Player/{id}/updateCoins
        [HttpPost("{id}/updateCoins")]
        public async Task<ActionResult> UpdateCoins(string id, [FromBody] UpdateCoinsRequest request)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
            {
                return NotFound();
            }

            player.Coins = (player.Coins ?? 0) + request.CoinsChange;
            
            // Ensure coins don't go negative
            if (player.Coins < 0)
            {
                player.Coins = 0;
            }

            await _context.SaveChangesAsync();
            
            return Ok(new { success = true, NewCoinsAmount = player.Coins });
        }

        // GET: api/Player/{id}/upgrades
        [HttpGet("{id}/upgrades")]
        public async Task<ActionResult<object>> GetPlayerUpgrades(string id)
        {
            var player = await _context.Players
                .Include(p => p.Upgrades)
                .FirstOrDefaultAsync(p => p.PlayerId == id);

            if (player == null)
            {
                return NotFound();
            }

            var upgrades = player.Upgrades.ToDictionary(
                u => u.UpgradeType.ToLower(),
                u => u.Level ?? 1
            );

            return Ok(upgrades);
        }

        // POST: api/Player/{id}/upgrades
        [HttpPost("{id}/upgrades")]
        public async Task<ActionResult> UpdatePlayerUpgrade(string id, [FromBody] UpdateUpgradeRequest request)
        {
            var player = await _context.Players
                .Include(p => p.Upgrades)
                .FirstOrDefaultAsync(p => p.PlayerId == id);

            if (player == null)
            {
                return NotFound();
            }

            var existingUpgrade = player.Upgrades
                .FirstOrDefault(u => u.UpgradeType.ToLower() == request.UpgradeType.ToLower());

            if (existingUpgrade != null)
            {
                existingUpgrade.Level = request.Level;
                existingUpgrade.UpdatedDate = DateTime.UtcNow;
            }
            else
            {
                var newUpgrade = new Upgrade
                {
                    PlayerId = id,
                    UpgradeType = request.UpgradeType,
                    Level = request.Level,
                    CreatedDate = DateTime.UtcNow,
                    UpdatedDate = DateTime.UtcNow
                };
                _context.Upgrades.Add(newUpgrade);
            }

            await _context.SaveChangesAsync();

            return Ok(new { success = true, UpgradeType = request.UpgradeType, Level = request.Level });
        }

        // DELETE: api/Player/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePlayer(string id)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
            {
                return NotFound();
            }

            _context.Players.Remove(player);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool PlayerExists(string id)
        {
            return _context.Players.Any(e => e.PlayerId == id);
        }
    }

    // Request models
    public class UpdatePlayerProfileRequest
    {
        public string? PlayerName { get; set; }
        public string? Gender { get; set; }
        public string? LanguagePreference { get; set; }
    }

    public class LoginRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class RegisterRequest
    {
        public string PlayerName { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Gender { get; set; }
        public string? LanguagePreference { get; set; }
    }

    public class UpdateCoinsRequest
    {
        public int CoinsChange { get; set; }
    }

    public class UpdateUpgradeRequest
    {
        public string UpgradeType { get; set; } = string.Empty;
        public int Level { get; set; }
    }
}
