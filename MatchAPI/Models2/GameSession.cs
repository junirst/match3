using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

public partial class GameSession
{
    [Key]
    [Column("SessionID")]
    public int SessionId { get; set; }

    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [StringLength(20)]
    public string GameMode { get; set; } = null!;

    [Column("ChapterID")]
    public int? ChapterId { get; set; }

    public int? LevelNumber { get; set; }

    public int? TowerFloor { get; set; }

    public DateTime? StartTime { get; set; }

    public DateTime? EndTime { get; set; }

    public bool? IsCompleted { get; set; }

    public int? FinalScore { get; set; }

    public bool? EnemyDefeated { get; set; }

    [ForeignKey("ChapterId")]
    [InverseProperty("GameSessions")]
    public virtual Chapter? Chapter { get; set; }

    [ForeignKey("PlayerId")]
    [InverseProperty("GameSessions")]
    public virtual Player Player { get; set; } = null!;
}
