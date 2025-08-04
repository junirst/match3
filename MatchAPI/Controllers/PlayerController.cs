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
                Progress = player.PlayerProgresses?.Select(p => new {
                    progressId = p.ProgressId,
                    playerId = p.PlayerId,
                    chapterId = p.ChapterId,
                    levelNumber = p.LevelNumber,
                    isCompleted = p.IsCompleted,
                    bestScore = p.BestScore,
                    completionDate = p.CompletionDate,
                    attemptsCount = p.AttemptsCount
                }).ToList(),
                Settings = player.PlayerSettings?.Select(s => new {
                    settingId = s.SettingId,
                    playerId = s.PlayerId,
                    bgmEnabled = s.Bgmenabled,
                    sfxEnabled = s.Sfxenabled,
                    bgmVolume = s.Bgmvolume,
                    sfxVolume = s.Sfxvolume,
                    language = s.Language,
                    firstLaunch = s.FirstLaunch,
                    updatedDate = s.UpdatedDate
                }).ToList(),
                Stats = player.PlayerStats?.Select(st => new {
                    statId = st.StatId,
                    playerId = st.PlayerId,
                    seasonId = st.SeasonId,
                    totalGamesPlayed = st.TotalGamesPlayed,
                    totalVictories = st.TotalVictories,
                    totalDefeats = st.TotalDefeats,
                    highestTowerFloor = st.HighestTowerFloor,
                    totalPlayTime = st.TotalPlayTime,
                    lastUpdated = st.LastUpdated
                }).ToList(),
                Weapons = player.PlayerWeapons?.Select(w => new {
                    playerWeaponId = w.PlayerWeaponId,
                    playerId = w.PlayerId,
                    weaponName = w.WeaponName,
                    isOwned = w.IsOwned,
                    purchaseDate = w.PurchaseDate
                }).ToList()
            };

            return profile;
        }

        // GET: api/Player/current-season
        [HttpGet("current-season")]
        public async Task<ActionResult<object>> GetCurrentSeason()
        {
            var currentSeason = await _context.Seasons
                .Where(s => s.IsActive == true)
                .FirstOrDefaultAsync();

            if (currentSeason == null)
            {
                return NotFound("No active season found");
            }

            return Ok(new
            {
                seasonId = currentSeason.SeasonId,
                seasonNumber = currentSeason.SeasonNumber,
                startDate = currentSeason.StartDate,
                endDate = currentSeason.EndDate,
                isActive = currentSeason.IsActive,
                createdDate = currentSeason.CreatedDate
            });
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

            if (request.TowerRecord.HasValue)
                player.TowerRecord = request.TowerRecord.Value;

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
            player.Coins = 500;
            player.TowerRecord = 0;

            _context.Players.Add(player);
            try
            {
                await _context.SaveChangesAsync();
                
                // Return a clean response without navigation properties to avoid JSON cycle
                return Created($"api/Player/{player.PlayerId}", new { 
                    Message = "Registration successful", 
                    Player = new {
                        PlayerId = player.PlayerId,
                        PlayerName = player.PlayerName,
                        Email = player.Email,
                        Gender = player.Gender,
                        LanguagePreference = player.LanguagePreference,
                        Coins = player.Coins,
                        TowerRecord = player.TowerRecord,
                        EquippedWeapon = player.EquippedWeapon,
                        CreatedDate = player.CreatedDate,
                        LastLoginDate = player.LastLoginDate,
                        IsActive = player.IsActive
                    }
                });
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
                Coins = 500, // Starting coins
                TowerRecord = 0
            };

            _context.Players.Add(player);
            
            // Get current active season
            var currentSeason = await _context.Seasons
                .Where(s => s.IsActive == true)
                .FirstOrDefaultAsync();
            
            if (currentSeason != null)
            {
                // Create initial Leaderboard entry
                var leaderboardEntry = new Leaderboard
                {
                    PlayerId = playerId,
                    SeasonId = currentSeason.SeasonId,
                    TowerLevel = 0,
                    Score = 0,
                    Rank = 0, // Will be calculated later
                    CreatedDate = DateTime.Now,
                    UpdatedDate = DateTime.Now
                };
                _context.Leaderboards.Add(leaderboardEntry);
            }

            // Create initial TowerProgress entry
            var towerProgress = new TowerProgress
            {
                PlayerId = playerId,
                CurrentFloor = 1,
                HighestFloor = 0,
                CurrentPlayerHealth = 100, // Default starting health
                ExcessHealth = 0,
                ShieldPoints = 0,
                PowerPoints = 0,
                LastPlayDate = DateTime.Now
            };
            _context.TowerProgresses.Add(towerProgress);

            // Create default weapon (Sword)
            var defaultWeapon = new PlayerWeapon
            {
                PlayerId = playerId,
                WeaponName = "Sword",
                IsOwned = true,
                PurchaseDate = DateTime.Now
            };
            _context.PlayerWeapons.Add(defaultWeapon);

            // Set equipped weapon to Sword
            player.EquippedWeapon = "Sword";

            try
            {
                await _context.SaveChangesAsync();
                
                // Return a clean response without navigation properties
                return Created($"api/Player/{player.PlayerId}", new { 
                    Message = "Registration successful", 
                    Player = new {
                        PlayerId = player.PlayerId,
                        PlayerName = player.PlayerName,
                        Email = player.Email,
                        Gender = player.Gender,
                        LanguagePreference = player.LanguagePreference,
                        Coins = player.Coins,
                        TowerRecord = player.TowerRecord,
                        EquippedWeapon = player.EquippedWeapon,
                        CreatedDate = player.CreatedDate,
                        LastLoginDate = player.LastLoginDate,
                        IsActive = player.IsActive
                    }
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

            // Validate new level is within allowed range
            const int maxUpgradeLevel = 15;
            if (request.Level > maxUpgradeLevel)
            {
                return BadRequest($"Maximum upgrade level is {maxUpgradeLevel}. Requested level: {request.Level}");
            }

            var existingUpgrade = player.Upgrades
                .FirstOrDefault(u => u.UpgradeType.ToLower() == request.UpgradeType.ToLower());

            if (existingUpgrade != null)
            {
                // Additional validation to ensure level is not decreasing
                if (request.Level < existingUpgrade.Level)
                {
                    return BadRequest($"Cannot downgrade from level {existingUpgrade.Level} to {request.Level}");
                }
                
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

            try
            {
                await _context.SaveChangesAsync();
                return Ok(new { success = true, UpgradeType = request.UpgradeType, Level = request.Level });
            }
            catch (DbUpdateException ex)
            {
                // Log the detailed exception
                Console.WriteLine($"DbUpdateException in UpdatePlayerUpgrade: {ex.Message}");
                Console.WriteLine($"Inner Exception: {ex.InnerException?.Message}");
                Console.WriteLine($"Stack Trace: {ex.StackTrace}");
                
                return StatusCode(500, $"Error updating upgrade: {ex.Message}");
            }
            catch (Exception ex)
            {
                // Log any other exceptions
                Console.WriteLine($"General Exception in UpdatePlayerUpgrade: {ex.Message}");
                Console.WriteLine($"Inner Exception: {ex.InnerException?.Message}");
                Console.WriteLine($"Stack Trace: {ex.StackTrace}");
                
                return StatusCode(500, $"Unexpected error: {ex.Message}");
            }
        }

        // POST: api/Player/{id}/purchaseUpgrade
        [HttpPost("{id}/purchaseUpgrade")]
        public async Task<ActionResult> PurchaseUpgrade(string id, [FromBody] PurchaseUpgradeRequest request)
        {
            // Log the incoming request for debugging
            Console.WriteLine($"PurchaseUpgrade Request - PlayerId: {id}, UpgradeType: {request.UpgradeType}, NewLevel: {request.NewLevel}, TotalCost: {request.TotalCost}");

            var player = await _context.Players
                .Include(p => p.Upgrades)
                .FirstOrDefaultAsync(p => p.PlayerId == id);

            if (player == null)
            {
                Console.WriteLine($"Player not found: {id}");
                return NotFound("Player not found");
            }

            Console.WriteLine($"Player found: {player.PlayerId}, Current Coins: {player.Coins}");

            // Validate new level is within allowed range
            const int maxUpgradeLevel = 15;
            if (request.NewLevel > maxUpgradeLevel)
            {
                Console.WriteLine($"Level validation failed: {request.NewLevel} > {maxUpgradeLevel}");
                return BadRequest($"Maximum upgrade level is {maxUpgradeLevel}. Requested level: {request.NewLevel}");
            }

            // Check if player has enough coins
            if (player.Coins < request.TotalCost)
            {
                Console.WriteLine($"Insufficient coins: {player.Coins} < {request.TotalCost}");
                return BadRequest("Insufficient coins");
            }

            var existingUpgrade = player.Upgrades
                .FirstOrDefault(u => u.UpgradeType.ToLower() == request.UpgradeType.ToLower());

            int newLevel = request.NewLevel;

            if (existingUpgrade != null)
            {
                Console.WriteLine($"Existing upgrade found: {existingUpgrade.UpgradeType} Level {existingUpgrade.Level}");
                
                // Additional validation to ensure level is not decreasing
                if (newLevel < existingUpgrade.Level)
                {
                    Console.WriteLine($"Level downgrade attempt: {existingUpgrade.Level} -> {newLevel}");
                    return BadRequest($"Cannot downgrade from level {existingUpgrade.Level} to {newLevel}");
                }
            }
            else
            {
                Console.WriteLine($"No existing upgrade found for {request.UpgradeType}");
            }

            try
            {
                if (existingUpgrade != null)
                {
                    existingUpgrade.Level = newLevel;
                    existingUpgrade.UpdatedDate = DateTime.UtcNow;
                }
                else
                {
                    var newUpgrade = new Upgrade
                    {
                        PlayerId = id,
                        UpgradeType = request.UpgradeType,
                        Level = newLevel,
                        CreatedDate = DateTime.UtcNow,
                        UpdatedDate = DateTime.UtcNow
                    };
                    _context.Upgrades.Add(newUpgrade);
                }

                // Deduct coins
                player.Coins -= request.TotalCost;

                await _context.SaveChangesAsync();
                
                return Ok(new 
                { 
                    success = true, 
                    upgradeType = request.UpgradeType, 
                    level = newLevel, 
                    remainingCoins = player.Coins 
                });
            }
            catch (DbUpdateException ex)
            {
                return StatusCode(500, "Error updating upgrade");
            }
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

        // POST: api/Player/{id}/purchaseWeapon
        [HttpPost("{id}/purchaseWeapon")]
        public async Task<ActionResult> PurchaseWeapon(string id, [FromBody] PurchaseWeaponRequest request)
        {
            var player = await _context.Players
                .Include(p => p.PlayerWeapons)
                .FirstOrDefaultAsync(p => p.PlayerId == id);

            if (player == null)
            {
                return NotFound("Player not found");
            }

            // Check if weapon already owned
            var existingWeapon = player.PlayerWeapons
                .FirstOrDefault(w => w.WeaponName == request.WeaponName);

            if (existingWeapon?.IsOwned == true)
            {
                return BadRequest("Weapon already owned");
            }

            // Check if player has enough coins
            if (player.Coins < request.Cost)
            {
                return BadRequest("Insufficient coins");
            }

            // Deduct coins
            player.Coins -= request.Cost;

            // Add or update weapon
            if (existingWeapon != null)
            {
                existingWeapon.IsOwned = true;
                existingWeapon.PurchaseDate = DateTime.Now;
            }
            else
            {
                _context.PlayerWeapons.Add(new PlayerWeapon
                {
                    PlayerId = id,
                    WeaponName = request.WeaponName,
                    IsOwned = true,
                    PurchaseDate = DateTime.Now
                });
            }

            try
            {
                await _context.SaveChangesAsync();
                
                // Return updated player data
                var updatedPlayer = await _context.Players
                    .Include(p => p.PlayerWeapons)
                    .FirstOrDefaultAsync(p => p.PlayerId == id);

                if (updatedPlayer == null)
                {
                    return StatusCode(500, "Error retrieving updated player data");
                }

                return Ok(new
                {
                    coins = updatedPlayer.Coins,
                    weapons = updatedPlayer.PlayerWeapons.Select(w => new {
                        playerWeaponId = w.PlayerWeaponId,
                        playerId = w.PlayerId,
                        weaponName = w.WeaponName,
                        isOwned = w.IsOwned,
                        purchaseDate = w.PurchaseDate
                    }).ToList()
                });
            }
            catch (DbUpdateException)
            {
                return StatusCode(500, "Error purchasing weapon");
            }
        }

        // PUT: api/Player/{id}/equipWeapon
        [HttpPut("{id}/equipWeapon")]
        public async Task<ActionResult> EquipWeapon(string id, [FromBody] EquipWeaponRequest request)
        {
            var player = await _context.Players
                .Include(p => p.PlayerWeapons)
                .FirstOrDefaultAsync(p => p.PlayerId == id);

            if (player == null)
            {
                return NotFound("Player not found");
            }

            // Check if player owns the weapon
            var weapon = player.PlayerWeapons
                .FirstOrDefault(w => w.WeaponName == request.WeaponName && w.IsOwned == true);

            if (weapon == null && request.WeaponName != "Sword") // Sword is always available
            {
                return BadRequest("Weapon not owned");
            }

            player.EquippedWeapon = request.WeaponName;

            try
            {
                await _context.SaveChangesAsync();
                return Ok(new { equippedWeapon = player.EquippedWeapon });
            }
            catch (DbUpdateException)
            {
                return StatusCode(500, "Error equipping weapon");
            }
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
        public int? TowerRecord { get; set; }
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

    public class PurchaseUpgradeRequest
    {
        public string UpgradeType { get; set; } = string.Empty;
        public int NewLevel { get; set; }
        public int TotalCost { get; set; }
    }

    public class PurchaseWeaponRequest
    {
        public string WeaponName { get; set; } = string.Empty;
        public int Cost { get; set; }
    }

    public class EquipWeaponRequest
    {
        public string WeaponName { get; set; } = string.Empty;
    }
}
