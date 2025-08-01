using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Table("PlayerProgress")]
[Index("PlayerId", "ChapterId", "LevelNumber", Name = "UQ__PlayerPr__06046FF468B42FD1", IsUnique = true)]
public partial class PlayerProgress
{
    [Key]
    [Column("ProgressID")]
    public int ProgressId { get; set; }

    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [Column("ChapterID")]
    public int ChapterId { get; set; }

    public int LevelNumber { get; set; }

    public bool? IsCompleted { get; set; }

    public int? BestScore { get; set; }

    public DateTime? CompletionDate { get; set; }

    public int? AttemptsCount { get; set; }

    [ForeignKey("ChapterId")]
    [InverseProperty("PlayerProgresses")]
    public virtual Chapter Chapter { get; set; } = null!;

    [ForeignKey("PlayerId")]
    [InverseProperty("PlayerProgresses")]
    public virtual Player Player { get; set; } = null!;
}
