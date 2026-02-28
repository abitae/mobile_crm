import React from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { Users, Briefcase } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../theme';
import type { Project } from '../types';

interface DashboardScreenProps {
  clientsCount: number;
  projects: Project[];
}

export function DashboardScreen({ clientsCount, projects }: DashboardScreenProps) {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.hero}>
        <Text style={styles.heroTitle}>¡Hola, Demo User!</Text>
        <Text style={styles.heroSubtitle}>Panel Inmobiliario Veridian</Text>
      </View>
      <View style={styles.cardsRow}>
        <View style={styles.card}>
          <View style={styles.cardIconBlue}>
            <Users size={16} color={colors.blue[500]} />
          </View>
          <Text style={styles.cardLabel}>Clientes</Text>
          <Text style={styles.cardValue}>{clientsCount}</Text>
        </View>
        <View style={styles.card}>
          <View style={styles.cardIconEmerald}>
            <Briefcase size={16} color={colors.emerald[500]} />
          </View>
          <Text style={styles.cardLabel}>Proyectos</Text>
          <Text style={styles.cardValue}>{projects.length}</Text>
        </View>
      </View>
      <Text style={styles.sectionTitle}>Proyectos Destacados</Text>
      {projects.slice(0, 2).map((project) => (
        <View key={project.id} style={styles.projectRow}>
          <View style={styles.projectIcon}>
            <Briefcase size={16} color={colors.zinc[400]} />
          </View>
          <View style={styles.projectInfo}>
            <Text style={styles.projectTitle}>{project.title}</Text>
            <Text style={styles.projectLocation}>{project.location}</Text>
          </View>
          <View style={styles.projectRight}>
            <Text style={styles.projectProgress}>{project.progress}%</Text>
            <Text style={styles.projectUnits}>{project.units} UNIDADES</Text>
          </View>
        </View>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { padding: spacing.lg, gap: spacing.lg },
  hero: { backgroundColor: colors.emerald[500], padding: spacing.xl, borderRadius: borderRadius.xl },
  heroTitle: { fontSize: 18, fontWeight: '700', color: colors.white },
  heroSubtitle: { fontSize: 12, color: 'rgba(255,255,255,0.8)' },
  cardsRow: { flexDirection: 'row', gap: spacing.md },
  card: {
    flex: 1,
    backgroundColor: colors.white,
    padding: spacing.lg,
    borderRadius: borderRadius.xl,
    borderWidth: 1,
    borderColor: colors.zinc[100],
  },
  cardIconBlue: {
    width: 32,
    height: 32,
    borderRadius: borderRadius.xl,
    backgroundColor: colors.blue[50],
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.sm,
  },
  cardIconEmerald: {
    width: 32,
    height: 32,
    borderRadius: borderRadius.xl,
    backgroundColor: colors.emerald[50],
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.sm,
  },
  cardLabel: { fontSize: 9, fontWeight: '700', color: colors.zinc[400], letterSpacing: 1 },
  cardValue: { fontSize: 18, fontWeight: '700', color: colors.zinc[900] },
  sectionTitle: { fontSize: 14, fontWeight: '700', color: colors.zinc[900] },
  projectRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: colors.white,
    padding: spacing.md,
    borderRadius: borderRadius.xl,
    borderWidth: 1,
    borderColor: colors.zinc[100],
  },
  projectIcon: {
    width: 32,
    height: 32,
    borderRadius: borderRadius.sm,
    backgroundColor: colors.zinc[50],
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: spacing.md,
  },
  projectInfo: { flex: 1 },
  projectTitle: { fontSize: 12, fontWeight: '700', color: colors.zinc[900] },
  projectLocation: { fontSize: 9, color: colors.zinc[400] },
  projectRight: { alignItems: 'flex-end' },
  projectProgress: { fontSize: 12, fontWeight: '700', color: colors.emerald[600] },
  projectUnits: { fontSize: 8, color: colors.zinc[400], fontWeight: '700' },
});
