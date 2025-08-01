using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Keyless]
public partial class VwCurrentSeasonLeaderboard
{
    public int? Rank { get; set; }

    [StringLength(100)]
    public string PlayerName { get; set; } = null!;

    public int TowerLevel { get; set; }

    public int? Score { get; set; }

    public DateTime? UpdatedDate { get; set; }

    public int SeasonNumber { get; set; }
}
