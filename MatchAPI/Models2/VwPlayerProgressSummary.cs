using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Keyless]
public partial class VwPlayerProgressSummary
{
    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [StringLength(100)]
    public string PlayerName { get; set; } = null!;

    [Column("ChapterID")]
    public int ChapterId { get; set; }

    [StringLength(100)]
    public string ChapterName { get; set; } = null!;

    public int? LevelsAttempted { get; set; }

    public int? LevelsCompleted { get; set; }

    public int? BestScore { get; set; }

    public int? TotalAttempts { get; set; }

    [Column(TypeName = "decimal(5, 2)")]
    public decimal? CompletionPercentage { get; set; }
}
