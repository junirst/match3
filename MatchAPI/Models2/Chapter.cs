using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

public partial class Chapter
{
    [Key]
    [Column("ChapterID")]
    public int ChapterId { get; set; }

    [StringLength(100)]
    public string ChapterName { get; set; } = null!;

    [StringLength(255)]
    public string? Description { get; set; }

    public bool? IsUnlocked { get; set; }

    public DateTime? CreatedDate { get; set; }

    [InverseProperty("Chapter")]
    public virtual ICollection<GameSession> GameSessions { get; set; } = new List<GameSession>();

    [InverseProperty("Chapter")]
    public virtual ICollection<Level> Levels { get; set; } = new List<Level>();

    [InverseProperty("Chapter")]
    public virtual ICollection<PlayerProgress> PlayerProgresses { get; set; } = new List<PlayerProgress>();
}
